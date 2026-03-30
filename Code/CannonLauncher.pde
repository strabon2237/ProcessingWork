//image frames in gif
int numFrames = 300;
//number of points (m x m)
int m = 40;

void setup() {
  //making the canvas
  size(700, 700);
  colorMode(HSB, 1); 
  noFill();
}

float periodicFunction(float p) {
  //size change based on exponential sin function
  return map(exp(sin((TWO_PI * p))), -1, 1, 8, 20);
}

float offset(float x, float y) {
  //offset function changes the size of each point accordingly based on position
  return 50 * dist(x, y, width/2, width/8);
}

void draw() {
  background(1); 

  float t = (float)frameCount / 60; 

  for (int i = 0; i < m; i++) {
    for (int j = 0; j < m; j++) {
      //Finding the point
      float x = map(i, 0, m-1, 0, width);
      float y = map(j, 0, m-1, 0, height);

      //Size of the point
      float size = periodicFunction(t - offset(x, y));
      strokeWeight(size);

      // time-evolving Perlin noise for the color
      float nx = i * 0.05;
      float ny = j * 0.05;
      float hue = noise(nx, ny, t);
      
      stroke(hue, 1, 1);

      // looping Perlin noise for displacement
      float px = x + map(noise(nx + 5, ny + 5), 0, 1, -10, 10);
      float py = y + map(noise(nx + 10, ny + 10), 0, 1, -10, 10);
      
      //draw point based on all the paramters set
      point(px, py);
    }
  }

  // Save frames for GIF
  if (frameCount <= numFrames) {
    saveFrame("frames/####.png");
  }
  if (frameCount == numFrames) {
    println("All frames have been saved");
  }
}
