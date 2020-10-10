function varargout = gui_Angie_Target_prediction(varargin)
% GUI_ANGIE_TARGET_PREDICTION MATLAB code for gui_Angie_Target_prediction.fig
%      GUI_ANGIE_TARGET_PREDICTION, by itself, creates a new GUI_ANGIE_TARGET_PREDICTION or raises the existing
%      singleton*.
%
%      H = GUI_ANGIE_TARGET_PREDICTION returns the handle to a new GUI_ANGIE_TARGET_PREDICTION or the handle to
%      the existing singleton*.
%
%      GUI_ANGIE_TARGET_PREDICTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ANGIE_TARGET_PREDICTION.M with the given input arguments.
%
%      GUI_ANGIE_TARGET_PREDICTION('Property','Value',...) creates a new GUI_ANGIE_TARGET_PREDICTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_Angie_Target_prediction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_Angie_Target_prediction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)". 
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_Angie_Target_prediction

% Last Modified by GUIDE v2.5 08-Mar-2018 12:55:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_Angie_Target_prediction_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_Angie_Target_prediction_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before gui_Angie_Target_prediction is made visible.
function gui_Angie_Target_prediction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_Angie_Target_prediction (see VARARGIN)
handles.output = hObject;   % Choose default command line output for single_target_gui
guidata(hObject, handles);  % Update handles structure
comp_name = lower(getenv('COMPUTERNAME'));
%%%%% GLOBAL VARIABLE DECLARATIONS
global dist;        global accel;   global decel;           global rep_num;                 global mot_movement_dir; 
global card_data;   global data;    global samplerate;      global motor_rot_per_meter;     global axisNo;     
global RampMode;    global BatID;   global ai;              global a;                       global b;
global addComment;  global PAUSE_TIME_AFTER_MOTION;         global floorMicDistFromBat;     global addCommentTP
global addCommentTP_Flag;
% Initialization of Global Variables
rep_num = 1;    aa = 1;         samplerate = 2.5e5;     RampMode = int32([1]);      duration = 10;  
% PAUSE_TIME_AFTER_MOTION = 3;    motor_rot_per_meter = 2.532; % 395 mm per rotation - UMD
PAUSE_TIME_AFTER_MOTION = 3;    motor_rot_per_meter = -6.23; % JHU
total_length = samplerate*duration;     BatID = varargin{1};
floorMicDistFromBat = 3; % meters - I might want to put this as a prompt

if(strcmp(comp_name,'nbkothar-mobl1'))
    mot_movement_dir = 'C:\PhD\Bat_Lab\Research\Target_Occlusion_platform\Data\Motor_data\';
else
    mot_movement_dir = 'C:\Users\batlab\Desktop\test_loadlib\Mot_movement_files\';
end
% mot_movement_dir = 'C:\Users\batlab\Desktop\test_loadlib\Mot_movement_files\';

addComment =    {'Distractor', ...
                'No Distractor', ... 
                'Distractor - Not good', ...
                'No Distractor - Not good', ... 
                'Distractor - flew off at the end', ...
                'No Distractor - flew off at the end', ... 
                'Excellent', ...
                'Good', ...
                'Other', ...
                'Not good', ...
                'Average', ...
                'Catch Trial - with target', ...
                'Catch Trial - no target', ...                
                'Very Good, but flew off at the very end', ...
                'Very Good, very faint buzz', ...
                'Very Good, did not buzz', ...                
                'Good, but impatient, not focused', ...
                'Good but quiet in parts', ...
                'Okay', ...
                'Okay, but impatient, not focused', ...
                'Okay, tracking but no steady vocalizations',  ...                
                'Missed initial motion', ...
                'Only buzz', ... 
                'delete',};
            
addCommentTP =  {'Other', 'Excellent', 'Buzzed at the end', 'Quite Good', 'Looking for it','delete', ...
                'Looking for it but not buzz', 'Okay, not great', ''};
% This sets up the initial plot - only do when we are invisible so window can get raised using gui_Angie_Target_prediction.
% if strcmp(get(hObject,'Visible'),'off')
%     plot(rand(5));
% end

% Changes made by Ninad - START
if(strcmp(comp_name,'nbkothar-mobl1'))
    cd C:\PhD\Bat_Lab\Research\temp_data
else
%     cd D:\rSC\training
%     cd D:\rSC\recording
    cd D:\Angie
end
dir_name = ([date,'_',BatID]);
eval (['mkdir ',dir_name,';cd ',dir_name]);
current_dir = pwd;
% axes(get(handles.axes1));
% SETUP THE NIDAQ INSTANCE
ai = daq.createSession('ni');

%% Create input channel
ai.addAnalogInputChannel('Dev1','ai0','Voltage'); % Floor microphone for vocalization
ai.addAnalogInputChannel('Dev1','ai8','Voltage'); % Sampling the TTL output
ai.addAnalogInputChannel('Dev1','ai2','Voltage'); % Floor microphone for echo
ai.Channels(1).TerminalConfig = 'SingleEnded';
ai.Channels(2).TerminalConfig = 'SingleEnded';
ai.Channels(3).TerminalConfig = 'SingleEnded';
ai.Rate = samplerate;

%% Create output channel
ai.addAnalogOutputChannel('Dev1','ao0','Voltage');

%% Create Output Channel for Vicon triggering
ai.addAnalogOutputChannel('Dev1', 'ao1', 'Voltage');
a = [zeros(1,1000) 5*ones(1,10000) zeros(1,total_length-11000)]; % TTL
b = [5*ones(1,1000) zeros(1,total_length-12000) 5*ones(1, 11000)]; % VICON trigger

% TTL - starts with 4ms of LOW, 40 ms of HIGH and then 4 ms LOW. Because the Nidaq output is buffered it should hold the 
% output to LOW for the rest of the trial
% a = [zeros(1,1000) ones(1,10000) zeros(1,1000)]; 
% VICON Trigger - starts with 4 ms of HIGH and then 44 ms of LOW. (this mimics a ground short). Because the Nidaq output
% is buffered it should hold the output to LOW for the rest of the trial
% b = [ones(1,1000) zeros(1,11000)]; % VICON trigger
% Load Motor Movement DLL

addpath('C:\Users\Public\small_flight_room\old_aerotech_pc\Visual Studio 2010\Projects\Trial_Folder64C\Trial_Dll64C'); % source and header files
addpath('C:\Users\Public\small_flight_room\old_aerotech_pc\Visual Studio 2010\Projects\Trial_Folder64C\x64\Debug'); % Dll path
addpath('C:\Program Files (x86)\Aerotech\Ensemble\CLibrary\Include');
addpath('C:\Program Files (x86)\Aerotech\Ensemble\CLibrary\Bin64');

% addpath('C:\Users\batlab\Documents\Visual Studio 2010\Projects\Trial_Folder64C\Trial_Dll64C'); % source and header files
% addpath('C:\Users\batlab\Documents\Visual Studio 2010\Projects\Trial_Folder64C\x64\Debug'); % Dll path
% addpath('C:\Program Files (x86)\Aerotech\Ensemble\CLibrary\Include');
% addpath('C:\Program Files (x86)\Aerotech\Ensemble\CLibrary\Bin64');

[c d] = loadlibrary('Trial_Dll64C.dll', 'Trial_Dll64C.h');
calllib('Trial_Dll64C', 'helloworld');
calllib('Trial_Dll64C', 'helloworld2')
calllib('Trial_Dll64C', 'ConnectMotor') % Connect with the motor
% Ninad changes - END



% UIWAIT makes gui_Angie_Target_prediction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_Angie_Target_prediction_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% PUSH BUTTON CALLBACKS START

% --- Executes on button press in pushbutton_1. - LINEAR MOTION
function pushbutton_1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Globals
    global axisNo;              global dist;        global accel;               global decel;   global RampMode;
    global mot_movement_dir;    global rep_num;     global motor_rot_per_meter; global ai;      global a;   
    global b;                   global card_data;   global data;                global BatID;   global addComment;
    global floorMicDistFromBat; global PAUSE_TIME_AFTER_MOTION;
%     clear ni_data;
    % Global Initialization
    card_data = [0, 0, 0]; data = [0, 0, 0];
    % Local Data declaration and Initialization
    motMovementFileLoad_Flag = 0;   comment = '';
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        ni_data.targetID = 'Move_Left';
        disp (['Trial#: ',num2str(rep_num),' Move_Left']);
    elseif(get(handles.radiobutton_RightMotor, 'Value'))
        ni_data.targetID = 'Move_Right';
        disp (['Trial#: ',num2str(rep_num),' Move_Right']);
    else
        uiwait(msgbox('ERROR: No Motor Axis selected. Please select and start again','error'));
        return;
    end
    % Store Details about the motor motion
    ni_data.vel = 8;    ni_data.dist = dist;    ni_data.accel = accel;   ni_data.decel = decel;
%     ni_data.vel = 2;    ni_data.dist = dist;    ni_data.accel = 4;   ni_data.decel = 3;
    % If Edit radio button is 'on' - ask user for new motor parameters.
    % NOTE - These parameters will have to be entered every time. I have still not found a way to make this permanent 
    % NOTE - Put ONLY those parameters which are specific to your function here. Do NOT put 'dist, accel and decel' here
    if(get(handles.radiobutton_EditParam, 'Value'))
        prompt={'Velocity:'};
        name='Change Motor Movement Parameters';   numlines=1;
        defaultanswer={num2str(ni_data.vel)};
        new_params = inputdlg(prompt,name,numlines,defaultanswer);
        ni_data.vel = str2double(new_params{1});
    end
    str = cellstr(num2str([ni_data.dist; ni_data.vel; ni_data.accel; ni_data.decel]));
    str = regexprep(str, '\.', '_');    str = regexprep(str, ' ', '');
    fn_str = strcat(mot_movement_dir, 'ML_',str{1}, '_Vel_', str{2}, '_ac_', str{3}, '_dc_', str{4}, '.mat');
    if(exist(fn_str, 'file'))
        load(strcat(fn_str));
        motMovementFileLoad_Flag = 1;
    else % actual displacement data does not exist - will have to use equations for this
        motMovementFileLoad_Flag = 0;
        mot_data = 0;
    end
    % Precautionary Checks to be done before Enabling Motor
    if((ni_data.dist > 4) || (ni_data.accel > 25) || (ni_data.decel > 25))
        uiwait(msgbox('ERROR: dist/accel/decel exceeds limit','Motor Parameter Limit Error','error'));
        return;
    end
    num_rev = ni_data.dist*motor_rot_per_meter;   speed = ni_data.vel;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        num_rev = -num_rev;
    end  

    %% add a listener
%     start_time = tic;
    lh = ai.addlistener('DataAvailable',@get_data);
    %% queue the output data    
    ai.queueOutputData ([a' b']); % trial    
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)    
    calllib('Trial_Dll64C', 'MotorSetupRampModeAxis', axisNo, RampMode)
    calllib('Trial_Dll64C', 'MotorSetupRampRateAccelAxis', axisNo, ni_data.accel)
    calllib('Trial_Dll64C', 'MotorSetupRampRateDecelAxis', axisNo, ni_data.decel)
    calllib('Trial_Dll64C', 'MotorFaultAck', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionSetupIncremental')
    tic1 = tic;
    ai.startBackground();
    ai_stbgnd = toc(tic1);
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev, ni_data.vel)
    motor_runtime = toc(tic1);
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
    clear tic1;
    pause(PAUSE_TIME_AFTER_MOTION);
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, -num_rev, ni_data.vel)
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
    ai.stop();
    delete(lh);
    % Data management - This is a common code for all motor movements
%         card_data = func_move_right(axisNo, RampMode, accelRate, decelRate, dist, speed);
    gui_data_management(hObject, eventdata, handles, ni_data, motor_runtime, ai_stbgnd, motMovementFileLoad_Flag, mot_data);
    
% --- Executes on button press in pushbutton_2. % VELOCITY CHANGE - LEFT AND RIGHT AXIS
function pushbutton_2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Globals
    global axisNo;              global dist;        global accel;               global decel;   global RampMode;
    global mot_movement_dir;    global rep_num;     global motor_rot_per_meter; global ai;      global a;   
    global b;                   global card_data;   global data;                global BatID;   global addComment;
    global floorMicDistFromBat; global PAUSE_TIME_AFTER_MOTION;
%     clear ni_data;
    % Global Initialization
    card_data = [0, 0, 0]; data = [0, 0, 0];
    % Local Data declaration and Initialization
    motMovementFileLoad_Flag = 0;   comment = '';
    tic;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        ni_data.targetID = 'VC_Left';
        disp (['Trial#: ',num2str(rep_num),' VC_Left']);
    elseif(get(handles.radiobutton_RightMotor, 'Value'))
        ni_data.targetID = 'VC_Right';
        disp (['Trial#: ',num2str(rep_num),' VC_Right']);
    else
        uiwait(msgbox('ERROR: No Motor Axis selected. Please select and start again','error'));
        return;
    end
    % Store Details about the motor motion - NOTE - for VC accel and decel global parameters are not used
    ni_data.vel = 8;        ni_data.vel_slow = 5;     ni_data.vel_last = 7;
    ni_data.dist = dist;    ni_data.accel = 15;          ni_data.decel = 15;
    
    % If Edit radio button is 'on' - ask user for new motor parameters.
    % NOTE - These parameters will have to be entered every time. I have still not found a way to make this permanent 
    % NOTE - Put ONLY those parameters which are specific to your function here. Do NOT put 'dist, accel and decel' here
    if(get(handles.radiobutton_EditParam, 'Value'))
        prompt={'Velocity:', 'Velocity Slow:',  'Velocity Last:','Acceleration:', 'Deceleration:'};
        name='Change Motor Movement Parameters';   numlines=1;
        defaultanswer={num2str(ni_data.vel), num2str(ni_data.vel_slow), num2str(ni_data.vel_last), num2str(ni_data.accel), ... 
            num2str(ni_data.decel)};
        new_params = inputdlg(prompt,name,numlines,defaultanswer);
        ni_data.vel = str2double(new_params{1});        ni_data.vel_slow = str2double(new_params{2});   
        ni_data.vel_last = str2double(new_params{3});   ni_data.accel = str2double(new_params{4});  
        ni_data.decel = str2double(new_params{5});
    end
    % Construct Motor Displacement File Name - Change this accordingly
    str = cellstr(num2str([ni_data.dist; ni_data.vel; ni_data.vel_slow; ni_data.vel_last; ni_data.accel; ni_data.decel]));
    str = regexprep(str, '\.', '_');    str = regexprep(str, ' ', '');
    fn_str = strcat(mot_movement_dir, 'VC_',str{1}, '_Vel_', str{2}, '_Vslow_', str{3}, '_Vlast_', str{4}, '_ac_', str{5}, '_dc_', str{6}, '.mat');
    if(exist(fn_str, 'file'))
        load(strcat(fn_str));
        motMovementFileLoad_Flag = 1;
    else % actual displacement data does not exist - will have to use equations for this
        motMovementFileLoad_Flag = 0;
        mot_data = 0;
    end
    % Precautionary Checks to be done before Enabling Motor
    if((ni_data.dist > 4) || (ni_data.accel > 25) || (ni_data.decel > 25))
        uiwait(msgbox('ERROR: dist/accel/decel exceeds limit','Motor Parameter Limit Error','error'));
        return;
    end
    num_rev = ni_data.dist*motor_rot_per_meter;   speed = ni_data.vel;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        num_rev = -num_rev;
    end
    

    %% add a listener
    lh = ai.addlistener('DataAvailable',@get_data);
    %% queue the output data
    ai.queueOutputData ([a' b']); % trial
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    calllib('Trial_Dll64C', 'MotorSetupRampModeAxis', axisNo, RampMode)
    calllib('Trial_Dll64C', 'MotorSetupRampRateAccelAxis', axisNo, ni_data.accel)
    calllib('Trial_Dll64C', 'MotorSetupRampRateDecelAxis', axisNo, ni_data.decel)
    calllib('Trial_Dll64C', 'MotorFaultAck', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionSetupIncremental')
    tic1 = tic;
    ai.startBackground();
    ai_stbgnd = toc(tic1);
    % Motor Motion Start
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev/3, ni_data.vel)
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev/3, ni_data.vel_slow)
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev/3, ni_data.vel_last)
    motor_runtime = toc(tic1);
    clear tic1
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
%     stop_time = toc;
    pause(PAUSE_TIME_AFTER_MOTION);
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, -num_rev, 2*ni_data.vel)
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
    ai.stop();
    delete(lh);
%     % Data management

    gui_data_management(hObject, eventdata, handles, ni_data, motor_runtime, ai_stbgnd, motMovementFileLoad_Flag, mot_data);

% --- Executes on button press in pushbutton 3 - Back and Forward
function pushbutton_3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Globals
    global axisNo;              global dist;        global accel;               global decel;   global RampMode;
    global mot_movement_dir;    global rep_num;     global motor_rot_per_meter; global ai;      global a;   
    global b;                   global card_data;   global data;                global BatID;   global addComment;
    global floorMicDistFromBat; global PAUSE_TIME_AFTER_MOTION;
%     clear ni_data;
    % Global Initialization
    card_data = [0, 0, 0]; data = [0, 0, 0];
    % Local Data declaration and Initialization
    motMovementFileLoad_Flag = 0;   comment = '';
    tic;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        ni_data.targetID = 'BaF_Left';
        disp (['Trial#: ',num2str(rep_num),' BaF_Left']);
    elseif(get(handles.radiobutton_RightMotor, 'Value'))
        ni_data.targetID = 'BaF_Right';
        disp (['Trial#: ',num2str(rep_num),' BaF_Right']);
    else
        uiwait(msgbox('ERROR: No Motor Axis selected. Please select and start again','error'));
        return;
    end
    % Store Details about the motor motion - NOTE - check if I want to use the same global 'accel' and 'decel' parameters for BaF
    ni_data.vel = 6;        ni_data.vel_back = 6;     ni_data.vel_final = 6;
    ni_data.dist = dist;    ni_data.accel = accel;          ni_data.decel = decel;
    
    % If Edit radio button is 'on' - ask user for new motor parameters. - Change this accordingly
    % NOTE - These parameters will have to be entered every time. I have still not found a way to make this permanent 
    % NOTE - Put ONLY those parameters which are specific to your function here. Do NOT put 'dist, accel and decel' here
    % NOTE - If you put accel, decel here then do not update the 'accel' and 'decel' global values
    if(get(handles.radiobutton_EditParam, 'Value'))
        prompt={'Velocity:', 'Velocity Back:',  'Velocity Final:','Acceleration:', 'Deceleration:'};
        name='Change Motor Movement Parameters';   numlines=1;
        defaultanswer={num2str(ni_data.vel), num2str(ni_data.vel_back), num2str(ni_data.vel_final), num2str(ni_data.accel), ... 
            num2str(ni_data.decel)};
        new_params = inputdlg(prompt,name,numlines,defaultanswer);
        ni_data.vel = str2double(new_params{1});        ni_data.vel_back = str2double(new_params{2});   
        ni_data.vel_final = str2double(new_params{3});  ni_data.accel = str2double(new_params{4});  
        ni_data.decel = str2double(new_params{5});
    end
    % Construct Motor Displacement File Name - Change this accordingly
    str = cellstr(num2str([ni_data.dist; ni_data.vel; ni_data.vel_back; ni_data.vel_final; ni_data.accel; ni_data.decel]));
    str = regexprep(str, '\.', '_');    str = regexprep(str, ' ', '');
    fn_str = strcat('BaF_Complex_',str{1}, '_Vel_', str{2}, '_Vback_', str{3}, '_Vfin_', str{4}, '_ac_', str{5}, '_dc_', str{6}, '.mat');
    if(exist(fn_str, 'file'))
        load(strcat(fn_str));
        motMovementFileLoad_Flag = 1;
    else % actual displacement data does not exist - will have to use equations for this
        motMovementFileLoad_Flag = 0;
        mot_data = 0;
    end
    % Precautionary Checks to be done before Enabling Motor
    if((ni_data.dist > 4) || (ni_data.accel> 25) || (ni_data.decel> 25))
        uiwait(msgbox('ERROR: dist/accel/decel exceeds limit','Motor Parameter Limit Error','error'));
        return;
    end
    num_rev = ni_data.dist*motor_rot_per_meter;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        num_rev = -num_rev;
    end
    num_rev1 = (4*num_rev)/5;       num_rev2 = ((-2)*num_rev)/5;    num_rev3 = (3*num_rev)/5;
%     if(((num_rev - sum([num_rev1 num_rev2 num_rev3]) > 0)) & (num_rev - sum([num_rev1 num_rev2 num_rev3]) < 0.001))
    if(((num_rev - sum([num_rev1 num_rev2 num_rev3]) >= 0.01)))  % - NEEDS TO BE DEBUGED
        uiwait(msgbox('ERROR: Incorrect Total BaF Complex Distance','BaF Displacement Error','error'));
        return;
    end
    
    %% add a listener
    lh = ai.addlistener('DataAvailable',@get_data);
    %% queue the output data
    ai.queueOutputData ([a' b']); % trial
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    calllib('Trial_Dll64C', 'MotorSetupRampModeAxis', axisNo, RampMode)
    calllib('Trial_Dll64C', 'MotorSetupRampRateAccelAxis', axisNo, ni_data.accel)
    calllib('Trial_Dll64C', 'MotorSetupRampRateDecelAxis', axisNo, ni_data.decel)
    calllib('Trial_Dll64C', 'MotorFaultAck', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionSetupIncremental')
    tic1 = tic;
    ai.startBackground();
    ai_stbgnd = toc(tic1);
    % Motor Motion Start
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev1, ni_data.vel)
    pause(0.1);
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev2, ni_data.vel_back)
    pause(0.1);
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev3, ni_data.vel_final)
    motor_runtime = toc(tic1);
    clear tic1
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
%     stop_time = toc;
    pause(PAUSE_TIME_AFTER_MOTION);
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, -num_rev, 2*ni_data.vel)
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
    ai.stop();
    delete(lh);
    % Data management
    gui_data_management(hObject, eventdata, handles, ni_data, motor_runtime, ai_stbgnd, motMovementFileLoad_Flag, mot_data);

%% --- Executes on button press in MS mismatch slow.
% This motion brings the target forward and then takes it backward. But
% then stops. It does not do the final forward motion

function BaF_catch1_Callback(hObject, eventdata, handles)
% hObject    handle to BaF_catch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Globals
    global axisNo;              global dist;        global accel;               global decel;   global RampMode;
    global mot_movement_dir;    global rep_num;     global motor_rot_per_meter; global ai;      global a;   
    global b;                   global card_data;   global data;                global BatID;   global addComment;
    global floorMicDistFromBat; global PAUSE_TIME_AFTER_MOTION;
%     clear ni_data;
    % Global Initialization
    card_data = [0, 0, 0]; data = [0, 0, 0];
    % Local Data declaration and Initialization
    motMovementFileLoad_Flag = 0;   comment = '';
    tic;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        ni_data.targetID = 'BaF_Left';
        disp (['Trial#: ',num2str(rep_num),' BaF_Left']);
    elseif(get(handles.radiobutton_RightMotor, 'Value'))
        ni_data.targetID = 'BaF_Right';
        disp (['Trial#: ',num2str(rep_num),' BaF_Right']);
    else
        uiwait(msgbox('ERROR: No Motor Axis selected. Please select and start again','error'));
        return;
    end
    % Store Details about the motor motion - NOTE - check if I want to use the same global 'accel' and 'decel' parameters for BaF
    ni_data.vel = 6;        ni_data.vel_back = 6;     ni_data.vel_final = 6;
    ni_data.dist = dist;    ni_data.accel = accel;          ni_data.decel = decel;
    
    % If Edit radio button is 'on' - ask user for new motor parameters. - Change this accordingly
    % NOTE - These parameters will have to be entered every time. I have still not found a way to make this permanent 
    % NOTE - Put ONLY those parameters which are specific to your function here. Do NOT put 'dist, accel and decel' here
    % NOTE - If you put accel, decel here then do not update the 'accel' and 'decel' global values
    if(get(handles.radiobutton_EditParam, 'Value'))
        prompt={'Velocity:', 'Velocity Back:',  'Velocity Final:','Acceleration:', 'Deceleration:'};
        name='Change Motor Movement Parameters';   numlines=1;
        defaultanswer={num2str(ni_data.vel), num2str(ni_data.vel_back), num2str(ni_data.vel_final), num2str(ni_data.accel), ... 
            num2str(ni_data.decel)};
        new_params = inputdlg(prompt,name,numlines,defaultanswer);
        ni_data.vel = str2double(new_params{1});        ni_data.vel_back = str2double(new_params{2});   
        ni_data.vel_final = str2double(new_params{3});  ni_data.accel = str2double(new_params{4});  
        ni_data.decel = str2double(new_params{5});
    end
    % Construct Motor Displacement File Name - Change this accordingly
    str = cellstr(num2str([ni_data.dist; ni_data.vel; ni_data.vel_back; ni_data.vel_final; ni_data.accel; ni_data.decel]));
    str = regexprep(str, '\.', '_');    str = regexprep(str, ' ', '');
    fn_str = strcat('BaF_Complex_',str{1}, '_Vel_', str{2}, '_Vback_', str{3}, '_Vfin_', str{4}, '_ac_', str{5}, '_dc_', str{6}, '.mat');
    if(exist(fn_str, 'file'))
        load(strcat(fn_str));
        motMovementFileLoad_Flag = 1;
    else % actual displacement data does not exist - will have to use equations for this
        motMovementFileLoad_Flag = 0;
        mot_data = 0;
    end
    % Precautionary Checks to be done before Enabling Motor
    if((ni_data.dist > 3) || (ni_data.accel> 25) || (ni_data.decel> 25))
        uiwait(msgbox('ERROR: dist/accel/decel exceeds limit','Motor Parameter Limit Error','error'));
        return;
    end
    num_rev = ni_data.dist*motor_rot_per_meter;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        num_rev = -num_rev;
    end
    num_rev1 = (num_rev)/3;       num_rev2 = (2*num_rev)/3;    num_rev3 = 0;
    if(num_rev - sum([num_rev1 num_rev2 num_rev3]) ~= 0)
        uiwait(msgbox('ERROR: Incorrect Total BaF Complex Distance','BaF Displacement Error','error'));
        return;
    end
    
    %% add a listener
    lh = ai.addlistener('DataAvailable',@get_data);
    %% queue the output data
    ai.queueOutputData ([a' b']); % trial
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    calllib('Trial_Dll64C', 'MotorSetupRampModeAxis', axisNo, RampMode)
    calllib('Trial_Dll64C', 'MotorSetupRampRateAccelAxis', axisNo, ni_data.accel)
    calllib('Trial_Dll64C', 'MotorSetupRampRateDecelAxis', axisNo, ni_data.decel)
    calllib('Trial_Dll64C', 'MotorFaultAck', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionSetupIncremental')
    tic1 = tic;
    ai.startBackground();
    ai_stbgnd = toc(tic1);
    % Motor Motion Start
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev1, ni_data.vel)
    pause(0.2);
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev2, 0.5*(ni_data.vel))
   % pause(0.1);
%     calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev3, ni_data.vel_final)
    motor_runtime = toc(tic1);
    clear tic1
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
%     stop_time = toc;
    pause(PAUSE_TIME_AFTER_MOTION);
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    
    % reverse motion to get line into starting position for next trial
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, -num_rev1*3, ni_data.vel)
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
    ai.stop();
    delete(lh);
    % Data management
    gui_data_management(hObject, eventdata, handles, ni_data, motor_runtime, ai_stbgnd, motMovementFileLoad_Flag, mot_data);
    
%% --- Executes on button press in Mismatch Fast
function BaF_catch2_Callback(hObject, eventdata, handles)
% hObject    handle to BaF_catch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Globals
    global axisNo;              global dist;        global accel;               global decel;   global RampMode;
    global mot_movement_dir;    global rep_num;     global motor_rot_per_meter; global ai;      global a;   
    global b;                   global card_data;   global data;                global BatID;   global addComment;
    global floorMicDistFromBat; global PAUSE_TIME_AFTER_MOTION;
%     clear ni_data;
    % Global Initialization
    card_data = [0, 0, 0]; data = [0, 0, 0];
    % Local Data declaration and Initialization
    motMovementFileLoad_Flag = 0;   comment = '';
    tic;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        ni_data.targetID = 'BaF_Left';
        disp (['Trial#: ',num2str(rep_num),' BaF_Left']);
    elseif(get(handles.radiobutton_RightMotor, 'Value'))
        ni_data.targetID = 'BaF_Right';
        disp (['Trial#: ',num2str(rep_num),' BaF_Right']);
    else
        uiwait(msgbox('ERROR: No Motor Axis selected. Please select and start again','error'));
        return;
    end
    % Store Details about the motor motion - NOTE - check if I want to use the same global 'accel' and 'decel' parameters for BaF
    ni_data.vel = 6;        ni_data.vel_back = 6;     ni_data.vel_final = 6;
    ni_data.dist = dist;    ni_data.accel = accel;          ni_data.decel = decel;
    
    % If Edit radio button is 'on' - ask user for new motor parameters. - Change this accordingly
    % NOTE - These parameters will have to be entered every time. I have still not found a way to make this permanent 
    % NOTE - Put ONLY those parameters which are specific to your function here. Do NOT put 'dist, accel and decel' here
    % NOTE - If you put accel, decel here then do not update the 'accel' and 'decel' global values
    if(get(handles.radiobutton_EditParam, 'Value'))
        prompt={'Velocity:', 'Velocity Back:',  'Velocity Final:','Acceleration:', 'Deceleration:'};
        name='Change Motor Movement Parameters';   numlines=1;
        defaultanswer={num2str(ni_data.vel), num2str(ni_data.vel_back), num2str(ni_data.vel_final), num2str(ni_data.accel), ... 
            num2str(ni_data.decel)};
        new_params = inputdlg(prompt,name,numlines,defaultanswer);
        ni_data.vel = str2double(new_params{1});        ni_data.vel_back = str2double(new_params{2});   
        ni_data.vel_final = str2double(new_params{3});  ni_data.accel = str2double(new_params{4});  
        ni_data.decel = str2double(new_params{5});
    end
    % Construct Motor Displacement File Name - Change this accordingly
    str = cellstr(num2str([ni_data.dist; ni_data.vel; ni_data.vel_back; ni_data.vel_final; ni_data.accel; ni_data.decel]));
    str = regexprep(str, '\.', '_');    str = regexprep(str, ' ', '');
    fn_str = strcat('BaF_Complex_',str{1}, '_Vel_', str{2}, '_Vback_', str{3}, '_Vfin_', str{4}, '_ac_', str{5}, '_dc_', str{6}, '.mat');
    if(exist(fn_str, 'file'))
        load(strcat(fn_str));
        motMovementFileLoad_Flag = 1;
    else % actual displacement data does not exist - will have to use equations for this
        motMovementFileLoad_Flag = 0;
        mot_data = 0;
    end
    % Precautionary Checks to be done before Enabling Motor
    if((ni_data.dist > 3) || (ni_data.accel> 25) || (ni_data.decel> 25))
        uiwait(msgbox('ERROR: dist/accel/decel exceeds limit','Motor Parameter Limit Error','error'));
        return;
    end
    num_rev = ni_data.dist*motor_rot_per_meter;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        num_rev = -num_rev;
    end
    num_rev1 = (num_rev)/3;       num_rev2 = (2*num_rev)/3;    num_rev3 = 0;
    if(num_rev - sum([num_rev1 num_rev2 num_rev3]) ~= 0)
        uiwait(msgbox('ERROR: Incorrect Total BaF Complex Distance','BaF Displacement Error','error'));
        return;
    end
    
    %% add a listener
    lh = ai.addlistener('DataAvailable',@get_data);
    %% queue the output data
    ai.queueOutputData ([a' b']); % trial
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    calllib('Trial_Dll64C', 'MotorSetupRampModeAxis', axisNo, RampMode)
    calllib('Trial_Dll64C', 'MotorSetupRampRateAccelAxis', axisNo, ni_data.accel)
    calllib('Trial_Dll64C', 'MotorSetupRampRateDecelAxis', axisNo, ni_data.decel)
    calllib('Trial_Dll64C', 'MotorFaultAck', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionSetupIncremental')
    tic1 = tic;
    ai.startBackground();
    ai_stbgnd = toc(tic1);
    % Motor Motion Start
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev1, ni_data.vel)
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev2, 4*(ni_data.vel))
%     pause(0.1);
%     calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, -num_rev2, ni_data.vel_final)
    motor_runtime = toc(tic1);
    clear tic1
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
%     stop_time = toc;
    pause(PAUSE_TIME_AFTER_MOTION);
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    
    % reverse motion to get line into starting position for next trial
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, -num_rev1*3, ni_data.vel)
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
    ai.stop();
    delete(lh);
    % Data management
    gui_data_management(hObject, eventdata, handles, ni_data, motor_runtime, ai_stbgnd, motMovementFileLoad_Flag, mot_data);
    
    
    
    
%% %%%%%%%%%%%%%%%%% START OF DATA MANAGEMENT FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gui_data_management(hObject, eventdata, handles, ni_data, motor_runtime, ai_stbgnd_lat, ...
    motMovementFileLoad_Flag, mot_data)
    global rep_num;     global card_data;       global BatID;       global addComment;    global floorMicDistFromBat;
    comment = '';
    
    mic_vect = card_data (:,1);
    ttl_vect = card_data (:,2);
    echo_vect = card_data (:,3);
    % Change gca
    set(gcf, 'CurrentAxes', handles.axes1);
    plot(mic_vect(1:5:end)); ylim ([-5 5]);
    if(motMovementFileLoad_Flag)
        set(gcf, 'CurrentAxes', handles.axes2);
        set(handles.text10, 'ForegroundColor', 'black');
        plot(mot_data.target_disp); ylim ([-0.1 max(mot_data.target_disp)]);
    else % the file does not exits
        set(handles.text10, 'ForegroundColor', 'red');
    end    
    
    % The addComment Popup Menu only comes up when not in the Training Phase.
    if(get(handles.radiobutton_addCommentTP, 'Value'))
            ni_data.mic_data = mic_vect;
            ni_data.ttl_data = ttl_vect;
            ni_data.echo_data = echo_vect;
            ni_data.ai_stbgnd_lat = ai_stbgnd_lat;
            ni_data.motor_runtime = motor_runtime;
            if rep_num < 10
                save_prefix = '0';
            else
                save_prefix = '';
            end
            ni_data.addComment = comment; % no comment added
            ni_data.floorMicDistFromBat = floorMicDistFromBat;
            save_str = (['save ',BatID,'_',save_prefix,num2str(rep_num),' ni_data']);
            eval(save_str);
            rep_num = rep_num + 1;
    else
        
        % Popup Menu (Save data, additional Comments and discard data)
        [s,v] = listdlg('PromptString','Additional Comments:', 'SelectionMode','single', 'ListSize', [300 300], ... 
                'ListString', addComment);
        if(v && strcmp(addComment{s},'delete')) % OK was pressed and 'delete' selected
            if(get(handles.radiobutton_EditParam, 'Value'))
                set(handles.radiobutton_EditParam, 'Value', 0)
            end
            return; % discard data - don't store anything
    %     elseif(v && (addComment{s} ~= 'delete'))
        else % if any other item was selected or even if 'Cancel' was selected
            ni_data.mic_data = mic_vect;
            ni_data.ttl_data = ttl_vect;
            ni_data.echo_data = echo_vect;
            ni_data.ai_stbgnd_lat = ai_stbgnd_lat;
            ni_data.motor_runtime = motor_runtime;
            if rep_num < 10
                save_prefix = '0';
            else
                save_prefix = '';
            end
            comment = addComment{s};
            ni_data.addComment = comment;
            ni_data.floorMicDistFromBat = floorMicDistFromBat;
            save_str = (['save ',BatID,'_',save_prefix,num2str(rep_num),' ni_data']);
            eval(save_str);
            rep_num = rep_num + 1;
        end
        if(get(handles.radiobutton_EditParam, 'Value'))
            set(handles.radiobutton_EditParam, 'Value', 0)
        end
    end
%%%%%%%%%%%%%%%%% END OF DATA MANAGEMENT FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    



% --- Executes on button press in pushbutton_quit.
function pushbutton_quit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%         ai.stop();
%         delete (lh);
        unloadlibrary  ( 'Trial_Dll64C');
        delete(handles.figure1);
        clear all;
        
% --- Executes on button press in addComment_TP.
function addComment_TP_Callback(hObject, eventdata, handles)
% hObject    handle to addComment_TP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global addCommentTP;    global rep_num;     global BatID;
local_rep_num = rep_num - 1;
if(get(handles.radiobutton_addCommentTP, 'Value'))
    [s,v] = listdlg('PromptString','Additional TP Comments:', 'SelectionMode','single', 'ListSize', [300 300], ...
        'ListString', addCommentTP);
    % Construct Previous Trial File Name
    if local_rep_num < 10
        save_prefix = '0';
    else
        save_prefix = '';
    end
    
    if(v && strcmp(addCommentTP{s},'delete')) % OK was pressed and 'delete' selected
        eval_str = (['delete ', BatID,'_',save_prefix,num2str(local_rep_num),'.mat']);
        eval(eval_str);
    else
        eval_str = (['load ', BatID,'_',save_prefix,num2str(local_rep_num),'.mat']);
        eval(eval_str);
        comment = addCommentTP{s};
        ni_data.addComment = comment;
        eval_str = (['save ', BatID,'_',save_prefix,num2str(local_rep_num),' ni_data']);
        eval(eval_str);
    end
    
end


%% PUSH BUTTON CALLBACKS END

%% RADIO BUTTON CALLBACKS START

% --- Executes on button press in radiobutton_LeftMotor.
function radiobutton_LeftMotor_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_LeftMotor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
leftMotorSetFlag = get(hObject,'Value') % returns toggle state of radiobutton_LeftMotor
if(leftMotorSetFlag)
    if(get(handles.radiobutton_RightMotor, 'Value'))
        set(handles.radiobutton_RightMotor, 'Value', 0);
    end
end
global axisNo;      axisNo = int32([2]);

% --- Executes on button press in radiobutton_RightMotor.
function radiobutton_RightMotor_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_RightMotor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rightMotorSetFlag = get(hObject,'Value') % returns toggle state of radiobutton_LeftMotor
if(rightMotorSetFlag)
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        set(handles.radiobutton_LeftMotor, 'Value', 0);
    end
end
global axisNo;      axisNo = int32([1]);


% --- Executes on button press in radiobutton_EditParam.
function radiobutton_EditParam_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_EditParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_EditParam

% --- Executes on button press in radiobutton_addCommentTP.
function radiobutton_addCommentTP_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_addCommentTP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global addCommentTP_Flag;
addCommentTP_Flag = get(hObject,'Value');

%% RADIO BUTTON CALLBACKS END


%% EDIT TEXT BOX CALLBACKS START

function edit_Dist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dist;
% Hints: get(hObject,'String') returns contents of edit_Dist as text
%        str2double(get(hObject,'String')) returns contents of edit_Dist as a double
dist = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_Dist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global dist;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
dist = str2double(get(hObject,'String')); % returns contents of edit_Dist as a double


function edit_Accel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Accel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Accel as text
%        str2double(get(hObject,'String')) returns contents of edit_Accel as a double
global accel;
accel = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_Accel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Accel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global accel;
accel = str2double(get(hObject,'String'));



function edit_Decel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Decel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Decel as text
%        str2double(get(hObject,'String')) returns contents of edit_Decel as a double
global decel;
decel = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_Decel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Decel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global decel;
decel = str2double(get(hObject,'String'));

%% EDIT TEXT BOX CALLBACKS END

%% POP UP MENU CALLBACKS START
% --- Executes on selection change in popupmenu_addcomment.
function popupmenu_addcomment_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_addcomment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_addcomment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_addcomment


% --- Executes during object creation, after setting all properties.
function popupmenu_addcomment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_addcomment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});

%% POP UP MENU CALLBACKS END

%% FILE MENU CALLBACKS START
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

function get_data(src,event)
global card_data;
global data;
% persistent data;

data = [data ; event.Data];
card_data = data;
% clear data;
snapnow;
% end


% --- Executes on button press in fast linear. 
function pushbutton11_Callback(hObject, eventdata, handles)

    % Globals
    global axisNo;              global dist;        global accel;               global decel;   global RampMode;
    global mot_movement_dir;    global rep_num;     global motor_rot_per_meter; global ai;      global a;   
    global b;                   global card_data;   global data;                global BatID;   global addComment;
    global floorMicDistFromBat; global PAUSE_TIME_AFTER_MOTION;
%     clear ni_data;
    % Global Initialization
    card_data = [0, 0, 0]; data = [0, 0, 0];
    % Local Data declaration and Initialization
    motMovementFileLoad_Flag = 0;   comment = '';
    tic;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        ni_data.targetID = 'CM_IT_Left';
        disp (['Trial#: ',num2str(rep_num),' CM_IT_Left']);
    elseif(get(handles.radiobutton_RightMotor, 'Value'))
        ni_data.targetID = 'CM_IT_Right';
        disp (['Trial#: ',num2str(rep_num),' CM_IT_Right']);
    else
        uiwait(msgbox('ERROR: No Motor Axis selected. Please select and start again','error'));
        return;
    end
       % Store Details about the motor motion
    ni_data.vel = 8;    ni_data.dist = dist;    ni_data.accel = accel;   ni_data.decel = decel;
%     ni_data.vel = 2;    ni_data.dist = dist;    ni_data.accel = 4;   ni_data.decel = 3;
    % If Edit radio button is 'on' - ask user for new motor parameters.
    % NOTE - These parameters will have to be entered every time. I have still not found a way to make this permanent 
    % NOTE - Put ONLY those parameters which are specific to your function here. Do NOT put 'dist, accel and decel' here
    if(get(handles.radiobutton_EditParam, 'Value'))
        prompt={'Velocity:'};
        name='Change Motor Movement Parameters';   numlines=1;
        defaultanswer={num2str(ni_data.vel)};
        new_params = inputdlg(prompt,name,numlines,defaultanswer);
        ni_data.vel = str2double(new_params{1});
    end
    str = cellstr(num2str([ni_data.dist; ni_data.vel; ni_data.accel; ni_data.decel]));
    str = regexprep(str, '\.', '_');    str = regexprep(str, ' ', '');
    fn_str = strcat(mot_movement_dir, 'ML_',str{1}, '_Vel_', str{2}, '_ac_', str{3}, '_dc_', str{4}, '.mat');
    if(exist(fn_str, 'file'))
        load(strcat(fn_str));
        motMovementFileLoad_Flag = 1;
    else % actual displacement data does not exist - will have to use equations for this
        motMovementFileLoad_Flag = 0;
        mot_data = 0;
    end
    % Precautionary Checks to be done before Enabling Motor
    if((ni_data.dist > 4) || (ni_data.accel > 25) || (ni_data.decel > 25))
        uiwait(msgbox('ERROR: dist/accel/decel exceeds limit','Motor Parameter Limit Error','error'));
        return;
    end
    num_rev = ni_data.dist*motor_rot_per_meter;   speed = ni_data.vel;
    if(get(handles.radiobutton_LeftMotor, 'Value'))
        num_rev = -num_rev;
    end  

    %% add a listener
%     start_time = tic;
    lh = ai.addlistener('DataAvailable',@get_data);
    %% queue the output data    
    ai.queueOutputData ([a' b']); % trial    
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)    
    calllib('Trial_Dll64C', 'MotorSetupRampModeAxis', axisNo, RampMode)
    calllib('Trial_Dll64C', 'MotorSetupRampRateAccelAxis', axisNo, ni_data.accel)
    calllib('Trial_Dll64C', 'MotorSetupRampRateDecelAxis', axisNo, ni_data.decel)
    calllib('Trial_Dll64C', 'MotorFaultAck', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionSetupIncremental')
    tic1 = tic;
    ai.startBackground();
    ai_stbgnd = toc(tic1);
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, num_rev, 4*(ni_data.vel))
    motor_runtime = toc(tic1);
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
    clear tic1;
    pause(PAUSE_TIME_AFTER_MOTION);
    calllib('Trial_Dll64C', 'MotorMotionEnable', axisNo)
    calllib('Trial_Dll64C', 'MotorMotionMoveInc', axisNo, -num_rev, ni_data.vel)
    calllib('Trial_Dll64C', 'MotorMotionDisable', axisNo)
    ai.stop();
    delete(lh);
    % Data management - This is a common code for all motor movements
%         card_data = func_move_right(axisNo, RampMode, accelRate, decelRate, dist, speed);
    gui_data_management(hObject, eventdata, handles, ni_data, motor_runtime, ai_stbgnd, motMovementFileLoad_Flag, mot_data);
