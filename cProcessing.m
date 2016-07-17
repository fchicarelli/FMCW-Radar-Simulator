classdef cProcessing
  properties
    afMixedSignalInf
    afMixedSignalSup

    afFiltredSignalInf
    afFiltredSignalSup

    mcFftsInf
    mcFftsSup

    mcFftsFinalInf
    mcFftsFinalSup

    mfSnrInf
    mfSnrSup

    miMaskInf
    miMaskSup

    afRangesDetected
    afSpeedsDetected

  end

  methods
    function obj = cProcessing(param, sg)
      % Mixing Signals
      obj.afMixedSignalSup = sg.afTxSignal .* sg.afRxSignalSup;
      obj.afMixedSignalInf = sg.afTxSignal .* sg.afRxSignalInf;

      obj = obj.lowPassFilter(param);
      obj = obj.computeFfts(param);
      obj = obj.integrateWindows(param);
      obj = obj.cfar(param);
      obj = obj.detectTargets(param);
      obj = obj.displayResults(param);

    end


    function obj = lowPassFilter(obj, param)
      % Designing a 10th-order Lowpass Butterworth Filter
      [b, a] = butter(10, 1*param.fBandwith/param.fSampleFreq);

      % Applying this filter to the signals
      obj.afFiltredSignalSup = filter(b, a, obj.afMixedSignalSup);
      obj.afFiltredSignalInf = filter(b, a, obj.afMixedSignalInf);
    end


    function obj = computeFfts(obj, param)
      n = param.iPointsPerMod;
      obj.mcFftsInf = zeros(param.iNumOfMod, n);
      obj.mcFftsSup = zeros(param.iNumOfMod, n);

      % Compute the fft for each modulation period
      for i=1:param.iNumOfMod
        obj.mcFftsInf(i,:) = fft(obj.afFiltredSignalInf((i-1)*n+1:i*n));
        obj.mcFftsSup(i,:) = fft(obj.afFiltredSignalSup((i-1)*n+1:i*n));

        obj.mcFftsInf(i,:) = fftshift(obj.mcFftsInf(i,:));
        obj.mcFftsSup(i,:) = fftshift(obj.mcFftsSup(i,:));
      end
    end


    function obj = integrateWindows(obj, param)
      for j=1:param.iPointsPerMod
        obj.mcFftsFinalInf(:,j) = fft(obj.mcFftsInf(:,j));
        obj.mcFftsFinalSup(:,j) = fft(obj.mcFftsSup(:,j));

        obj.mcFftsFinalInf(:,j) = fftshift(obj.mcFftsFinalInf(:,j));
        obj.mcFftsFinalSup(:,j) = fftshift(obj.mcFftsFinalSup(:,j));
      end
    end


    function obj =  cfar(obj, param)
      obj.mfSnrInf = zeros(param.iNumOfMod, param.iPointsPerMod);
      obj.mfSnrSup = zeros(param.iNumOfMod, param.iPointsPerMod);
      obj.miMaskInf = zeros(param.iNumOfMod, param.iPointsPerMod);
      obj.miMaskSup = zeros(param.iNumOfMod, param.iPointsPerMod);

      fNoiseLevel = mean(abs(obj.mcFftsInf(1,:)));
      afSnr = abs(obj.mcFftsInf(1,:)) / fNoiseLevel;
      [dummy iPeaks] = findpeaks(afSnr, 'MinPeakHeight', param.fCFAR);

      for j=1:size(iPeaks,2)
          fNoiseLevel = mean(abs(obj.mcFftsFinalInf(:,iPeaks(j))));
          afSnr = abs(obj.mcFftsFinalInf(:,iPeaks(j))) / fNoiseLevel;
          [dummy iPeaks2] = findpeaks(afSnr, 'MinPeakHeight', param.fCFAR);
          obj.miMaskInf(iPeaks2, iPeaks(j)) = 1;
      end
    end


    function obj = detectTargets(obj, param)
      [indFd indFp] = find(obj.miMaskInf == 1);
      iTargetsDetected = size(indFp,1);

      for i=1:iTargetsDetected
        fRange = obj.computeRange(param, indFp(i));
        fSpeed = obj.computeSpeed(param, indFd(i));

        if fRange > 0
          obj.afRangesDetected = [obj.afRangesDetected fRange];
          obj.afSpeedsDetected = [obj.afSpeedsDetected fSpeed];
        end
      end
    end


    function fRange = computeRange(obj, param, indFp)
      fFp = -param.fSampleFreq/2 + param.fSampleFreq*indFp/param.iPointsPerMod;
      fRange = fFp*param.c*param.fModTime/(2*param.fBandwith);
    end


    function fSpeed = computeSpeed(obj, param, indFd)
      iFd = -1./(param.fModTime*2) + indFd/(param.fModTime*param.iNumOfMod);
      fSpeed = iFd*param.c/(2*param.fCarrierFreq);
    end


    function obj = displayResults(obj, param)
      figure; hold on;
      grid on;
      xlabel('Range (m)')
      ylabel('Speed (m/s)');
      title('Targets');
      
      disp(['=== Targets simulated ===']);
      for i=1:param.iNumOfTargets
        fRange = sqrt(param.targets(i).x^2+param.targets(i).y^2+param.targets(i).z^2);
        fSpeed = sqrt(param.targets(i).vx^2+param.targets(i).vy^2+param.targets(i).vz^2);
        disp(['Target #', num2str(i), ': Range = ', num2str(fRange), ...
                  'm  Speed = ', num2str(fSpeed), 'm/s']);

        plot(fRange, fSpeed, 'ks');
      end

      disp('')
      disp(['=== Targets detected ===']);
      for i=1:size(obj.afRangesDetected, 2)
        disp(['Target #', num2str(i), ': Range = ', num2str(obj.afRangesDetected(i)), ...
                  'm  Speed = ', num2str(obj.afSpeedsDetected(i)), 'm/s']);
        plot(obj.afRangesDetected(i), obj.afSpeedsDetected(i), 'r.');
      end

    end

  end

end
