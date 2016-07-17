classdef cParameters
  properties
    % Constants
    c

    % Frequencies
    fBandwith
    fSampleFreq
    fCarrierFreq

    % Periods
    fObsTime
    fModTime
    iNumOfMod
    iPointsPerMod

    % Targets
    iNumOfTargets
    targets

    % Antennas
    antennaTx
    antennaRxSup
    antennaRxInf

    %
    fCFAR

  end

  methods
    function obj = cParameters()
      obj.c = 3e8;

      obj.fBandwith = 50e6;
      obj.fSampleFreq = 100e6;
      obj.fCarrierFreq = 10e9;

      obj.fObsTime = 5e-3;
      obj.iNumOfMod = 625;
      obj.fModTime = obj.fObsTime / obj.iNumOfMod;
      obj.iPointsPerMod = floor(obj.fModTime*obj.fSampleFreq);

      obj.iNumOfTargets = 1;
      obj.targets = [];
      for i = 1:obj.iNumOfTargets
        obj.targets = [obj.targets cTarget(i)];
      end

      obj.antennaTx = cAntenna();
      obj.antennaRxSup = cAntenna();
      obj.antennaRxInf = cAntenna();

      obj.fCFAR = 13;

    end

  end

end
