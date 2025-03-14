classdef (Abstract) SimulationConfiguration < handle

    %% Properties
    properties (Access = private, Constant)
        interface_function_names = ["environment", ...
                                    "sensors", ...
                                    "actuators", ...
                                    "plantDynamics", ...
                                    "plantOutput", ...
                                    "gncAlgorithms", ...
                                    "sendSimData", ...
                                    "stopCriterion"]
    end

    properties (SetAccess = immutable, GetAccess = public)
        parameters_cells (:,1) cell
        BusesInfo (:,1) struct
        simulation_inputs (:,1) Simulink.SimulationInput
    end

    properties (SetAccess = private, GetAccess = public)
        simulation_outputs (:,1) Simulink.SimulationOutput
    end
    
    %% Non-Static Methods
    % (can access the object)

    methods (Access = public)

        % Default Constructor
        function obj = SimulationConfiguration()

            % Call static methods to set property values

            % Parameters
            obj.parameters_cells = SimulationConfiguration.codeWrapper(@() obj.configureParameters(), "Configuring Parameters");
            
            % Buses
            obj.BusesInfo = SimulationConfiguration.codeWrapper(@() obj.configureBuses(obj.parameters_cells), "Configuring Buses");
            
            % Simulation Inputs
            obj.simulation_inputs = SimulationConfiguration.codeWrapper(@() obj.configureSimulationInputs(obj.parameters_cells, obj.BusesInfo), "Configuring Simulation Inputs");
            
        end

        % Execute Simulations
        run(obj, use_parsim)
    
    end

    methods (Access = private, Sealed)
        createSimulinkInterfaceFiles(obj)
    end
    

    %% Static Methods
    % (no access to objects)
    
    % Abstract methods must be defined in subclass
    methods (Abstract, Static, Access = public)    
        Parameters = configureParameters()
        BusesInfo = configureBuses(Parameters)

        [EnvironmentConditions, ...
            LogEnvironment, ...
            EnvironmentStatesDerivatives] ...
            = environment(EnvironmentConditions, ...
                            LogEnvironment, ...
                            EnvironmentStatesDerivatives, ...
                            PlantOutputs, ...
                            simulation_time__s, ...
                            EnvironmentStates, ...
                            ParametersEnvironment)
        
        [SensorsOutputs, ...
            LogSensors, ...
            SensorsStatesUpdateInput] ...
            = sensors(SensorsOutputs, ...
                        LogSensors, ...
                        SensorsStatesUpdateInput, ...
                        EnvironmentConditions, ...
                        PlantOutputs, ...
                        PlantFeedthrough, ...
                        SensorsStates, ...
                        ParametersSensors)

        [ActuatorsOutputs,...
            LogActuators, ...
            ActuatorsStatesUpdateInput] ...
            = actuators(ActuatorsOutputs, ...
                        LogActuators, ...
                        ActuatorsStatesUpdateInput, ...
                        EnvironmentConditions, ...
                        DynamicsOutputs, ...
                        ActuatorsCommands, ...
                        ActuatorsStates, ...
                        ParametersActuators)
                                
        [PlantFeedthrough, ...
            LogPlantDynamics, ...    
            PlantStatesDerivatives] ...
            = plantDynamics(PlantFeedthrough, ...
                                LogPlantDynamics, ...
                                PlantStatesDerivatives, ...
                                EnvironmentConditions, ...
                                ActuatorsOutputs, ...
                                PlantStates, ...
                                ParametersPlant)

        [PlantOutputs, ...
            LogPlantOutput] ...
            = plantOutput(PlantOutputs, ...
                            LogPlantOutput, ...
                            PlantStates, ...
                            ParametersPlant)

        [ActuatorsCommands, ...
            LogGncAlgorithms, ...
            GncAlgorithmsStatesUpdateInput] ...
            = gncAlgorithms(ActuatorsCommands, ...
                            LogGncAlgorithms, ...
                            GncAlgorithmsStatesUpdateInput, ...
                            SensorsOutputs, ...
                            GncAlgorithmsStates, ...
                            ParametersGncAlgorithms)

        [udp_data_vector, LogSendSimData] ...
            = sendSimData(LogSendSimData, ...
                            simulation_time__s, ...
                            LogEnvironment, ...
                            LogSensors, ...
                            LogActuators, ...
                            LogPlantDynamics, ...
                            LogPlantOutput,...
                            LogGncAlgorithms, ...
                            Parameters)

        [stop_criterion, LogStopCriterion] ...
            = stopCriterion(LogStopCriterion, ...
                            simulation_time__s, ...
                            LogEnvironment, ...
                            LogSensors, ...
                            LogActuators, ...
                            LogPlantDynamics, ...
                            LogPlantOutput,...
                            LogGncAlgorithms, ...
                            Parameters)
    end

    % Defined in this class but can be overwritten
    methods (Static, Access = public)    
        simulation_inputs = configureSimulationInputs(Parameters, BusesInfo)
    end

    % Sealed methods cannot be overwritten
    methods (Static, Access = protected, Sealed)

        simulation_inputs = createSimulationInputs(parameters_cells, BusesInfo)

        varargout = codeWrapper(the_function, the_message)    
    end

end