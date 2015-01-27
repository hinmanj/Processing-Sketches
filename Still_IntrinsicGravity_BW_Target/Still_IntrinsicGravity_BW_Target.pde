boolean USE_COLOR = true;
boolean INVERT_MOVEMENT = false;

double nextInvertTimeMillis = 8000; //first at 8 seconds

PVector[] circles = new PVector[40];
float radiusMult = 70;
float lerpRate = 0.075;
float radiusLerpRate = 0.005; //smaller for faster movements

float cosMult = 1.0;
float sinMult = 1.0;

void setup() {
  size(1680, 1050);
  background(255);
  noStroke();
  fill(0);
  
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

void draw() {
  if ( (keyPressed && key == 'z') || nextInvertTimeMillis < millis())
  {
     INVERT_MOVEMENT = !INVERT_MOVEMENT; 
     
     nextInvertTimeMillis = millis() + random(5000, 10000);
     cosMult = random(0.8, 2.0);
     sinMult = random(0.8, 2.0);
     radiusMult = random(50, 90);
  }
  
  float desiredX = (width / 2.0) + cos(millis() / 1000.0) * (width / 4.0) * cosMult;
  float desiredY = (height / 2.0) + sin(millis() / 1000.0) * (height / 4.0) * sinMult;
  
  for (int i = 0; i < circles.length; i++)
  {
    float radius = (i + 1) * radiusMult;
    
    if (i == 0) //smallest circle
    {
      if (mousePressed == true)
      {
        desiredX = mouseX;
        desiredY = mouseY;
      }
      
      
      circles[i].x += (desiredX - circles[i].x) * lerpRate;
      circles[i].y += (desiredY - circles[i].y) * lerpRate;
    }
    else
    {
      if (mousePressed == true)
      {        
        if (USE_COLOR && i % 2 == 0)
        {
           circles[i].z = int(random(128, 255));
        }
      }
      else
      {
        if (i % 2 == 0)
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
  }
    
  for (int i = circles.length - 1; i >= 0; i--)
  {
    float radius = (i) * radiusMult;    
    fill(circles[i].z);
    if (!(i == 0 && INVERT_MOVEMENT))
      {
        ellipse(circles[i].x, circles[i].y, radius, radius);
      }
  }
  
}


