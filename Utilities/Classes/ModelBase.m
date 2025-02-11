classdef (Abstract) ModelBase < handle

    properties (SetAccess = protected, GetAccess = public)
        Parameters (1,1) struct
        Setup (1,:) SimulinkModelParameter
    end

    methods (Abstract, Static)
        execute
    end

    methods (Access = public)

        function obj = ModelBase(NameValueArgs)
            arguments
                NameValueArgs.Parameters (1,1) struct = struct()
                NameValueArgs.Setup (1,:) SimulinkModelParameter = SimulinkModelParameter.empty(1,0)
            end

            obj.Parameters = NameValueArgs.Parameters;
            obj.Setup = NameValueArgs.Setup;
        end

    end

end