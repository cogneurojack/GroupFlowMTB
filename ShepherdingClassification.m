function[dog1Classification, dog2Classification] = ShepherdingClassification(dog1, dog2, PolePos)

%GLOBAL PARAMETERS THAT NEED TO BE ADJUSTED BASED ON EXPERIMENTAL SETUP.
samplerate = 50;     %FILE SAMPLE RATE.
windowSize = 512;    %WINDOW SIZE FOR FREQUENCY SPECTRUM ANALYSSIS.
windowOverlap = 0.5; %OVERLAP WINDOW FOR FREQUENCY SPECTRUM ANALYSIS.


%% Convert Cartesian coordinates to Polar.
[dog1_theta, dog2_theta] = cartesian2polar(dog1, dog2, PolePos);

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

