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
PolePos = nan(length(data),2);
PolePosxy = [700 5025];
PolePos(:,1)=PolePosxy(1);
PolePos(:,2)=PolePosxy(2);

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

cd('/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/GroupFlowMTB')
[dog1_theta, dog2_theta] = cartesian2polar(dog1, dog2, PolePos);
cd('/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/GroupFlowMTB')
[dog1Classification, dog2Classification]= ShepherdingClassification(dog1, dog2, PolePos);
