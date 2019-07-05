%%% COMPUTES S&R/COC CLASSIFICATION FOR DYADIC 'SHEPHERDING' TASK PER
%%% NALEPKA ET AL. (2017; 2019).
%--------------------------------------------------------------------------
% LOAD THE DATA

dataFolder = '/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/Data/Pilot Data';

cd(dataFolder)

myFolderInfo = dir(dataFolder);

numFiles = length(myFolderInfo);

n=3;
while n < numFiles

loadFile = myFolderInfo(n).name;


thisFile = importdata(loadFile);
data = thisFile.data;


n=n+1;
end
%--------------------------------------------------------------------------
% CREATE THE PARAMETERS

names = thisFile.textdata;

% PARAMETERS: 
%   dog1: [n,2] matrix of (x,y) positions for player 1 over n timepoints.
%   dog2: [n,2] matrix of (x,y) positions for player 1 over n timepoints.
dog1 = data(:,18:19);
dog2 = data(:,19:20);
%   polePos: [n, 2] matrix of (x,y) positions of the polar center over n
%       timepoints. For static locations (such as a target center), the (x,y)
%       position is the same for each row.
% THE CENTRAL PIXEL OF THE SCREEN)
polePos = nan(length(data),2);
PolePos(:,(1:2)) = [(1400/2) (1050/2)];

%   NOTE: THE "Y" COLUMN FOR THE ABOVE PARAMETERS IS THE VERTICAL DIMENSION
%   ON THE TASK SCREEN. (EXAMPLE PLAYERS BEGIN A TRIAL ON THE +Y OR -Y OF
%   THE SCREEN.
%
%   OUTPUT:
%   dog1Classification: player 1 behavior classification. Positive values
%       indicate COC behavior, negative indicate S&R. The magnitude indicates
%       the strength of the classification. BY DEFAULT THE CUTOFF MOVEMENT
%       FREQUENCY IS 0.5 HZ FOR CLASSIFICATION (SUCH THAT BEHAVIOR > 0.5 HZ
%       IS CLASSIFIED AS COC).

%   dog2Classification: player 2 behavior classification. Positive values
%       indicate COC behavior, negative indicate S&R. The magnitude indicates
%       the strength of the classification. BY DEFAULT THE CUTOFF MOVEMENT
%       FREQUENCY IS 0.5 HZ FOR CLASSIFICATION (SUCH THAT BEHAVIOR > 0.5 HZ
%       IS CLASSIFIED AS COC).
%--------------------------------------------------------------------------

function [dog1Classification, dog2Classification] = ShepherdingClassification(dog1, dog2, polePos)

%GLOBAL PARAMETERS THAT NEED TO BE ADJUSTED BASED ON EXPERIMENTAL SETUP.
samplerate = 50;     %FILE SAMPLE RATE.
windowSize = 512;    %WINDOW SIZE FOR FREQUENCY SPECTRUM ANALYSSIS.
windowOverlap = 0.5; %OVERLAP WINDOW FOR FREQUENCY SPECTRUM ANALYSIS.


%% Convert Cartesian coordinates to Polar.
[dog1_theta, dog2_theta] = cart2pol(dog1, dog2, polePos);

%% Filter Data using 4th Order Band-Pass Butterworth Filter. Filter above 10Hz
butterOrder = 4;
highfilterCutoff = 10;
[weight_b,weight_a] = butter(butterOrder,highfilterCutoff/(samplerate/2));
dog1Ang = filtfilt(weight_b,weight_a,dog1_theta);
dog2Ang = filtfilt(weight_b,weight_a,dog2_theta);

%% Linear Detrend player's angular behavior.
x = detrend(dog1Ang);
y = detrend(dog2Ang);
 
%% Determine FFT Parameters
window = hanning(windowSize);           % window function
n_overlap = windowSize*windowOverlap;   % number of samples overlap                 
 
%% Calculate Spectrum for each timeseries.   
[power1,freq1] = pwelch(x,window,n_overlap,windowSize,samplerate,'power');                    
[power2,freq2] = pwelch(y,window,n_overlap,windowSize,samplerate,'power');
FP1 = [power1,freq1];
FP2 = [power2,freq2];

%%Find peak frequency that is less than lowfilterCutoff.
lowfilterCutoff = 2;
[powerMax_1,indx1] = max(FP1((FP1(:,2) < lowfilterCutoff),1));
[powerMax_2,indx2] = max(FP2((FP2(:,2) < lowfilterCutoff),1));
Freq1 = FP1(FP1(:,1)==powerMax_1,2);
Freq2 = FP2(FP2(:,1)==powerMax_2,2);

%Obtain classification. Value > 0 indicate Oscillatory behavior, < 0
%indicate S&R behavior. The magnitude of value indicate strength of
%classification.
dog1Classification = powerMax_1*(Freq1-0.5)/(abs(Freq1-0.5));
dog2Classification = powerMax_2*(Freq2-0.5)/(abs(Freq2-0.5));
end

function [dog1_theta, dog2_theta] = cart2pol(dog1, dog2, polePos)

%Center data from polar center.
dog1 = dog1-polePos;
dog2 = dog2-polePos;

%Compute angle using ATAN2.
dog1_theta = atan2(dog1(:,2), dog1(:,1));
dog2_theta = atan2(dog2(:,2), dog1(:,1));
end