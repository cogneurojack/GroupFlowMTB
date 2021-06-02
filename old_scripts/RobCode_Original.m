
SheepIn = true;
for(i = 0; i < NSheep; i++)
{
	// check if sheep are in the red area
	// cpw2sq is square of radius of red area in px
	SheepdX = SheepX[i]-ScreenCenterX;
	SheepdY = SheepY[i]-ScreenCenterY;
	SheepD = (SheepdX*SheepdX)+(SheepdY*SheepdY);
	if(SheepD > cpw2sq) SheepIn = false;
}

if(!SheepIn)
{
	SheepWinLog[Frames%NSHEEPWINLOG] = 0;
	SheepIn = true;
}
else
	SheepWinLog[Frames%NSHEEPWINLOG] = 1;
Frames++;


// terminate trial if sheep are in corale for 70% time in the last 45 seconds
// time is actually in frames ie 675 frames is 45 seconds and 470 frames is 70% of the time
TotalSheepWinTime = 0;
for(i = 0; i < NSHEEPWINLOG; i++) TotalSheepWinTime += SheepWinLog[i];
CurrentWinPercent = 100*TotalSheepWinTime/675;
if(TotalSheepWinTime >= 470)
{
	SheepWin = true;
	EscapeHit = true;
}
else
{
	if(TotalSheepWinTime > MaxWinTime) MaxWinTime = TotalSheepWinTime;
}

