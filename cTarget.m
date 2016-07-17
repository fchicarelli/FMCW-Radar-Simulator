classdef cTarget
  properties
    % Position
    x
    y
    z
    vx
    vy
    vz
    rcs
  end

  methods
    function obj = cTarget(i)
      obj.x = 100*i;
      obj.y = 0;
      obj.z = 0;
      obj.vx = 15*i;
      obj.vy = 0;
      obj.vz = 0;

      obj.rcs = 1;
    end
  end
end
