function [dog1_theta, dog2_theta, dog1_rad, dog2_rad] = cartesian2polar(dog1, dog2, PolePos)

%Center data from polar center.
dog1 = dog1-PolePos;
dog2 = dog2-PolePos;

%Compute angle using ATAN2.
dog1_theta = atan2(dog1(:,2), dog1(:,1));
dog2_theta = atan2(dog2(:,2), dog1(:,1));

dog1_rad = hypot(dog1(:,1),dog1(:,2));
dog2_rad = hypot(dog2(:,1),dog2(:,2));
end

