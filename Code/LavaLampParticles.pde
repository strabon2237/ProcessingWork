//Defining the amount of particles per row/column
int cols = 30;
int rows = 30;

//Properties of each particle stored in 2d arry
float[][] xPos;
float[][] yPos;
float[][] xVel;
float[][] yVel;
float[][] sizeNoise;
float[][] colorNoise;

void setup() {
  size(800, 800);
  noStroke();
  
  //initialize properties based on number of particles
  xPos = new float[cols][rows];
  yPos = new float[cols][rows];
  xVel = new float[cols][rows];
  yVel = new float[cols][rows];
  sizeNoise = new float[cols][rows];
  colorNoise = new float[cols][rows];
  
  //Give each particle a random starting value
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      xPos[i][j] = random(width);
      yPos[i][j] = random(height);
      xVel[i][j] = map(noise(random(1000)), 0, 1, -2, 2);
      yVel[i][j] = map(noise(random(1000)), 0, 1, -2, 2);
      sizeNoise[i][j] = random(1000);
      colorNoise[i][j] = random(1000);
    }
  }
}

void draw() {
  background(20);
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      // update position
      xPos[i][j] += xVel[i][j];
      yPos[i][j] += yVel[i][j];
      
      // bounce off walls
      float circleSize = map(noise(sizeNoise[i][j]), 0, 1, 10, 50);
      float radius = circleSize / 2;
      
      if (xPos[i][j] < radius || xPos[i][j] > width - radius) {
        xVel[i][j] *= -1;
      }
      if (yPos[i][j] < radius || yPos[i][j] > height - radius) {
        yVel[i][j] *= -1;
      }
      
      //  color change
      float redShade = map(noise(colorNoise[i][j]), 0, 1, 50, 255);  // wider range
      float greenShade = map(noise(colorNoise[i][j] + 10), 0, 1, 0, 80); // slight variation
      float blueShade = map(noise(colorNoise[i][j] + 20), 0, 1, 0, 80);  // slight variation
      float alpha = map(noise(colorNoise[i][j] + 5), 0, 1, 150, 255);    // more opaque
      
      fill(redShade, greenShade, blueShade, alpha);
      ellipse(xPos[i][j], yPos[i][j], circleSize, circleSize);
      
      // Noise increments for dynamic change
      sizeNoise[i][j] += 0.02;
      colorNoise[i][j] += 0.04; 
    }
  }
}
