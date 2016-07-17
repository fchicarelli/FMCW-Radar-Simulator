classdef cAntenna
  properties
    x
    y
    z

    fGain
  end

  methods
    function obj = cAntenna()
      obj.x = 0;
      obj.y = 0;
      obj.z = 0;
      obj.fGain = 1;
    end
  end

end
