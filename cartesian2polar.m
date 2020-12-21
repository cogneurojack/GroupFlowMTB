function [dog1_theta, dog2_theta] = cartesian2polar(dog1, dog2, polePos)

%Center data from polar center.
dog1 = dog1-polePos;
dog2 = dog2-polePos;

%Compute angle using ATAN2.
dog1_theta = atan2(dog1(:,2), dog1(:,1));
dog2_theta = atan2(dog2(:,2), dog1(:,1));
end

