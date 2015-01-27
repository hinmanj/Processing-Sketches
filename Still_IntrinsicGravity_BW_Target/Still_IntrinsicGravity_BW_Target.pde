boolean USE_COLOR = true;

PVector[] circles = new PVector[40];
float radiusMult = 70;
float lerpRate = 0.1;
float radiusLerpRate = 0.005; //smaller for faster movements

void setup() {
  size(1680, 1050);
  background(0);
  noStroke();
  fill(0);
  
  for (int i = 0; i < circles.length; i++)
  {
    float fillColor = 0;
    if (i % 2 == 1)
    {
       fillColor = 255;
    }
    circles[i] = new PVector((float)width / 2, (float)height / 2, fillColor);
  }
}

void draw() {
  
  
  float desiredX = (width / 2.0) + cos(millis() / 1000.0) * (width / 4.0);
  float desiredY = (height / 2.0) + sin(millis() / 1000.0) * (height / 4.0);
  
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
        if (USE_COLOR && i % 2 == 1)
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
      float xDiff = circles[0].x - (width / 2);
      circles[i].x = (width / 2) + map(xDiff, -width / 2, width / 2, -1, 1) * (circles.length - i) * radiusMult / (width * 0.002);  //(radius / 2)
      
      float yDiff = circles[0].y - (height / 2);
      circles[i].y = (height / 2) + map(yDiff, -height / 2, height / 2, -1, 1) * (circles.length - i) * radiusMult / (height * 0.0052); //(radius / 2)
    }
  }
    
  for (int i = circles.length - 1; i >= 0; i--)
  {
    float radius = (i + 1) * radiusMult;    
    fill(circles[i].z);
    ellipse(circles[i].x, circles[i].y, radius, radius);
  }
  
}


