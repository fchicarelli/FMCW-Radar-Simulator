classdef cSignalGenerator
  properties
    % Periods
    afTime
    afTimeN

    % Signals
    afTxSignal
    afRxSignalSup
    afRxSignalInf

  end

  methods
    % Constructor
    function obj = cSignalGenerator(param)
      % Periods
      obj.afTime = 0:1./param.fSampleFreq:param.fObsTime;
      obj.afTimeN = mod(obj.afTime, param.fModTime);

      % Generating Tx Signal
      obj.afTxSignal = obj.generateTxSignal(param);

      % Generating Rx Signal
      for i=1:param.iNumOfTargets
        if i == 1
          obj.afRxSignalSup = obj.generateRxSignal(param, i, 0);
          obj.afRxSignalInf = obj.generateRxSignal(param, i, 1);
        else
          obj.afRxSignalSup = obj.afRxSignalSup + obj.generateRxSignal(param, i, 0);
          obj.afRxSignalInf = obj.afRxSignalInf + obj.generateRxSignal(param, i, 1);
        end
      end

    end

    function afTxSignal = generateTxSignal(obj, param)
      % Creating the transmited signal
      % TODO: Add noise
      % TODO: Add antenna gain
      % TODO: Add antenna diagram
      % TODO: Transform the chirp to complex
      % TODO: Add more than one modulation
      afTxSignal = 100*cos(2*pi*param.fCarrierFreq*obj.afTime + ...
                        pi*param.fBandwith*(obj.afTimeN.^2)/param.fModTime);

      phi = (param.fCarrierFreq - param.fBandwith/2)*obj.afTimeN + ...
                param.fBandwith * (obj.afTimeN.^2) / (2*param.fModTime);
      afTxSignal = exp(j*2*pi*phi);

      end

    function afRxSignal = generateRxSignal(obj, param, targetNum, antennaNum)
      % TODO: Add noise
      % TODO: Add antenna gain
      % TODO: Add antenna diagram
      % TODO: Transform the chirp to complex

      % Selecting antenna. 0 for RxSup, 1 for RxInf
      if antennaNum == 0
        antenna = param.antennaRxSup;
      else
        antenna = param.antennaRxInf;
      end

      % Moving targets and then calculating range
      x = param.targets(targetNum).x + obj.afTime * param.targets(targetNum).vx;
      y = param.targets(targetNum).y + obj.afTime * param.targets(targetNum).vy;
      z = param.targets(targetNum).z + obj.afTime * param.targets(targetNum).vz;
      afRange = sqrt((x - antenna.x).^2 + (y - antenna.y).^2 + (z - antenna.z).^2);


      afDelay = 2*afRange/param.c;
      afRxSignal = 100*(1./(afRange.^0)) .* cos(2*pi*param.fCarrierFreq*(obj.afTime-afDelay) + ...
        pi*param.fBandwith*mod(obj.afTime-afDelay, param.fModTime).^2/param.fModTime);

      phi = (param.fCarrierFreq - param.fBandwith/2)*mod(obj.afTimeN-afDelay, param.fModTime) + ...
                param.fBandwith * (mod(obj.afTimeN-afDelay, param.fModTime).^2) / (2*param.fModTime);
      afRxSignal = exp(j*2*pi*phi);

    end
  end
end
