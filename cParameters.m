classdef cParameters
  properties
    % Parameters file
    sConfigFile
    xmlDoc

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
      obj.sConfigFile = 'parameters.xml';
      obj.xmlDoc = xml2struct(obj.sConfigFile);

      obj.c = 3e8;

      obj.fBandwith = str2num(obj.extractDataXml({'bandwith'}));
      obj.fSampleFreq = str2num(obj.extractDataXml({'sample_frequency'}));
      obj.fCarrierFreq = str2num(obj.extractDataXml({'carrier_frequency'}));

      obj.fObsTime = str2num(obj.extractDataXml({'observation_time'}));
      obj.fModTime = str2num(obj.extractDataXml({'modulation_time'}));
      obj.iNumOfMod = floor(obj.fObsTime / obj.fModTime);
      obj.iPointsPerMod = floor(obj.fModTime*obj.fSampleFreq);

      obj.iNumOfTargets = str2num(obj.extractDataXml({'number_of_targets'}));
      obj.targets = [];
      for i = 1:obj.iNumOfTargets
        sTarget = ['target', num2str(i)];
        obj.targets = [obj.targets cTarget( ...
          str2num(obj.extractDataXml({'targets', sTarget, 'x'})), ...
          str2num(obj.extractDataXml({'targets', sTarget, 'y'})), ...
          str2num(obj.extractDataXml({'targets', sTarget, 'z'})), ...
          str2num(obj.extractDataXml({'targets', sTarget, 'vx'})), ...
          str2num(obj.extractDataXml({'targets', sTarget, 'vy'})), ...
          str2num(obj.extractDataXml({'targets', sTarget, 'vz'})), ...
          str2num(obj.extractDataXml({'targets', sTarget, 'rcs'})) ...
        )];
      end

      obj.antennaTx = cAntenna( ...
        str2num(obj.extractDataXml({'antennas', 'antenna1', 'x'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna1', 'y'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna1', 'z'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna1', 'gain'})) ...
      );
      obj.antennaRxSup = cAntenna( ...
        str2num(obj.extractDataXml({'antennas', 'antenna2', 'x'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna2', 'y'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna2', 'z'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna2', 'gain'})) ...
      );
      obj.antennaRxInf =  cAntenna( ...
        str2num(obj.extractDataXml({'antennas', 'antenna3', 'x'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna3', 'y'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna3', 'z'})), ...
        str2num(obj.extractDataXml({'antennas', 'antenna3', 'gain'})) ...
      );

      obj.fCFAR = str2num(obj.extractDataXml({'cfar'}));

    end

    function value = extractDataXml(obj, fields)
      xmlNode = obj.xmlDoc;
      for i=1:size(fields, 2)
        for j=1:size(xmlNode.Children, 2)
          xmlChild = xmlNode.Children(j);
          if strcmp(xmlChild.Name, fields(i)) == 1
            xmlNode = xmlChild;
            break
          end
        end
      end
      value = xmlNode.Children(1).Data;
    end
  end

end
