import ddf.minim.*;
import ddf.minim.analysis.*;


boolean USE_COLOR = false;
boolean INVERT_MOVEMENT = false;

double nextInvertTimeMillis = 8000; //first at 8 seconds

int S_NUM_CIRCLES = 40;
PVector[] circles = new PVector[S_NUM_CIRCLES];
float radiusMult = 70;
float lerpRate = 0.075;
float radiusLerpRate = 0.005; //smaller for faster movements

float cosMult = 1.0;
float sinMult = 1.0;

float previousAvgFFT = 1;
float lerpRateToAvg = 0.012;

Minim mMinim;
AudioInput mLineIn;
FFT mFFT;

void setup()
{
  size(1680, 1050,P3D);
  background(255);
  noStroke();
  fill(0);
  setupAudio();
  for (int i = 0; i < circles.length; i++)
  {
    float fillColor = 0;
    if (i % 2 == 0)
    {
       fillColor = 255;
    }
    circles[i] = new PVector((float)width / 2, (float)height / 2, fillColor);
  }
  
}

void setupAudio()
{
  mMinim=new Minim(this);
  mLineIn = mMinim.getLineIn(Minim.STEREO, 2048);
  mFFT = new FFT(mLineIn.bufferSize(),mLineIn.sampleRate());
  mFFT.linAverages(S_NUM_CIRCLES);
}

void draw()
{
  background(255);

  mFFT.forward(mLineIn.mix);
  PVector cFFTVals = getMinMaxFFT();
  float cMapped = map(cFFTVals.z, cFFTVals.x, cFFTVals.y,1,10);
  USE_COLOR = mousePressed;
  if ( (keyPressed && key == 'z') || nextInvertTimeMillis < millis())
  {
     INVERT_MOVEMENT = !INVERT_MOVEMENT; 
     
     nextInvertTimeMillis = millis() + random(5000, 10000);
     cosMult = random(0.8, 2.0);
     sinMult = random(0.8, 2.0);
     radiusMult = 70;//random(60, 80);
  }
  
  float desiredX = (width / 2.0) + cos(millis() / 1000.0) * (width / 4.0) * cosMult;
  float desiredY = (height / 2.0) + sin(millis() / 1000.0) * (height / 4.0) * sinMult;
  
  for (int i = 0; i < circles.length; i++)
  {
    float radius = (i + 1) * radiusMult * mFFT.getAvg(i);
    
    if (i == 0) //smallest circle
    {
      //if (mousePressed == true)
      if (USE_COLOR == true)
      {
        desiredX = mouseX;
        desiredY = mouseY;
      }
      
      circles[i].x += (desiredX - circles[i].x) * lerpRate;
      circles[i].y += (desiredY - circles[i].y) * lerpRate;
    }
    else
    {
      if (USE_COLOR == true)
      {        
        if (/*USE_COLOR && */i % 2 == 1)
        {
           circles[i].z = int(random(128, 255));
        }
      }
      
      else
      {
        if (i % 2 == 1)
        {
           circles[i].z = 255;
        }
      }
      //float xDiff = circles[0].x - (width / 2);
      //float yDiff = circles[0].y - (height / 2);
      float xDiff = desiredX - (width / 2);
      float yDiff = desiredY - (height / 2);
      
      if (INVERT_MOVEMENT)
      {
        circles[i].x += (((width / 2) + map(xDiff, -width / 2, width / 2, -1, 1) * (i + 1) * radiusMult / (width * 0.002)) - circles[i].x) * lerpRate;  //(radius / 2)
        circles[i].y += (((height / 2) + map(yDiff, -height / 2, height / 2, -1, 1) * (i + 1) * radiusMult / (height * 0.002)) - circles[i].y) * lerpRate; //(radius / 2)
      }
      else
      {
        circles[i].x += (((width / 2) + map(xDiff, -width / 2, width / 2, -1, 1) * (circles.length - i) * radiusMult / (width * 0.002)) - circles[i].x) * lerpRate;  //(radius / 2)
        circles[i].y += (((height / 2) + map(yDiff, -height / 2, height / 2, -1, 1) * (circles.length - i) * radiusMult / (height * 0.0052) - circles[i].y) * lerpRate); //(radius / 2)
      }
    }
    circles[i].x = constrain(circles[i].x,0,width);
    circles[i].y = constrain(circles[i].y,0,height);
  }
    
    for (int i = circles.length - 1; i >= 0; i--)
    {
      boolean soundIsOn = false;
      float cFFTV = mFFT.getAvg(i);
      println(cFFTV);
      if (cFFTV < 0.1)
      {
        cFFTV = max(cFFTV, 0.1);
      } 
      else
      {
         soundIsOn = true; 
      }
      //float cM = map(cFFTV, cFFTVals.x, cFFTVals.y,0.95,1.05);
      float cM = map(cFFTV, 0.1, 3, 0.8, 1.6);//map(cFFTV, 5, 0.1,0.95,1.05);
      constrain(cM,0.8,2);
      if (!soundIsOn)
        cM = 1.0;
        
      previousAvgFFT += ((cM - previousAvgFFT) * lerpRateToAvg); //lerp to desired average so it's not so shaky.
      
      float cB = map(cFFTV, cFFTVals.x, cFFTVals.y,128,255);
       constrain(cB,128,255);

      float radius = (i) * radiusMult;// * cFFTV;
      if (USE_COLOR && i % 2 == 1)
      {
          fill(0, cB, circles[i].z);
      }
      else if (i % 2 == 1)
      {
           fill(0);
      }
       else
      {
          fill(circles[i].z);
          //fill(cB);
      
          radius= radius * previousAvgFFT;//cM;//min(radius, radius*cM);          
      } 
          //radius= radius * previousAvgFFT;//min(radius, radius*cM);      
          
      if (!(i == 0 && INVERT_MOVEMENT))
      {
        ellipse(circles[i].x, circles[i].y, radius, radius);
      }
   }
}

PVector getMinMaxFFT()
{
  float cMin = 1000;
  float cMax = -1;
  float cVal = 0;
  for (int i = 0; i < mFFT.avgSize (); i++)
  {
    float cr = mFFT.getAvg(i);
    if (cr<cMin)
      cMin=cr;
    else if (cr>=cMax)
      cMax=cr;
    cVal+=cr;
  }
  cVal/=mFFT.avgSize();
  return new PVector(cMin, cMax, cVal);
}
