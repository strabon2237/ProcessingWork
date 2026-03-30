//number of X patters and points per X Pattern
int numFields = 40;
int pointsPerLine = 10;

//Defining the Xs
Field[] fields;

void setup() {
  size(700, 700);
  
  fields = new Field[numFields];
  
  //unique position for each X field
  for (int i = 0; i < numFields; i++) {
    float x = random(width*0.2, width*0.8);
    float y = random(height*0.2, height*0.8);
    fields[i] = new Field(x, y, i * 1000); 
  }
}

void draw() {
  fill(0, 30);
  noStroke();
  rect(0, 0, width, height);
  
  for (Field f : fields) {
    f.update();
  }
  
  for (Field f : fields) {
    f.display();
  }
}

// Defining the Properties of the Field
class Field {
  //Separated into two diagonals
  Particle[] diag1;
  Particle[] diag2;
  
  float cx, cy;
  float baseX, baseY;
  
  float t;
  float angle;
  float size;
  
  float noiseOffset;
  
  Field(float x, float y, float nOff) {
    baseX = x;
    baseY = y;
    cx = x;
    cy = y;
    
    noiseOffset = nOff;
    
    //Creating the diagonal patterns
    diag1 = new Particle[pointsPerLine];
    diag2 = new Particle[pointsPerLine];
    
    for (int i = 0; i < pointsPerLine; i++) {
      diag1[i] = new Particle(cx, cy);
      diag2[i] = new Particle(cx, cy);
    }
    
    t = random(100);
    angle = random(TWO_PI);
  }
  
  void update() {
    t += 0.04;
    
    // Perlin drift of center
    float nx = noise(noiseOffset, t * 0.2);
    float ny = noise(noiseOffset + 100, t * 0.2);
    
    cx = baseX + map(nx, 0, 1, -100, 100);
    cy = baseY + map(ny, 0, 1, -100, 100);
    
    //Perlin noise rotation
    float spin = map(noise(noiseOffset + 200, t * 0.3), 0, 1, -0.03, 0.03);
    angle += spin;
    
    size = map(sin(t), -1, 1, 20, 200);
    float half = size / 2;
    
    //Apply to each point of the diagonal
    for (int i = 0; i < pointsPerLine; i++) {
      float amt = map(i, 0, pointsPerLine-1, -1, 1);
      
      // Base X
      float x1 = amt * half;
      float y1 = amt * half;
      
      float x2 = amt * half;
      float y2 = -amt * half;
      
      // Add noise distortion to each point
      float n = noise(noiseOffset + i * 0.1, t * 0.5);
      float distort = map(n, 0, 1, -15, 15);
      
      x1 += distort;
      y1 += distort;
      x2 -= distort;
      y2 += distort;
      
      // Rotate
      float tx1 = x1*cos(angle) - y1*sin(angle);
      float ty1 = x1*sin(angle) + y1*cos(angle);
      
      float tx2 = x2*cos(angle) - y2*sin(angle);
      float ty2 = x2*sin(angle) + y2*cos(angle);
      
      //Updating each point
      diag1[i].update(cx + tx1, cy + ty1);
      diag2[i].update(cx + tx2, cy + ty2);
    }
  }
  
  void display() {
    stroke(255);
    strokeWeight(2);
    
    for (int i = 0; i < pointsPerLine; i++) {
      diag1[i].display();
      diag2[i].display();
    }
  }
}

// Particle Properties
class Particle {
  float x, y;
  float vx, vy;
  
  float stiffness = 0.01;
  float damping = 0.9;
  
  Particle(float startX, float startY) {
    x = startX;
    y = startY;
  }
  
  void update(float tx, float ty) {
    float ax = (tx - x) * stiffness;
    float ay = (ty - y) * stiffness;
    
    vx += ax;
    vy += ay;
    
    vx *= damping;
    vy *= damping;
    
    x += vx;
    y += vy;
  }
  
  void display() {
    point(x, y);
  }
}
