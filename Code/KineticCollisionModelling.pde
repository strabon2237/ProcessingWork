int numParticles = 200;
Particle[] particles;
float k = 0.0015; // first-order rate constant
float dt = 100;     // time step per frame

ArrayList<Float> progressHistory = new ArrayList<Float>();
int graphWidth = 400;
int graphHeight = 150;

void setup() {
  size(800, 800);
  particles = new Particle[numParticles];
  for (int i = 0; i < numParticles; i++) {
    particles[i] = new Particle(random(width), random(height));
  }
}

void draw() {
  background(30);
  
  // calculate overall reaction progress
  int numReacted = 0;
  int numReactants = 0;
  for (int i = 0; i < numParticles; i++) {
    if (particles[i].state == 1) numReacted++;
    else numReactants++;
  }
  float X = float(numReacted) / numParticles;  // fraction converted
  
  // expected fraction to convert this step based on kinetics
  float deltaX = k * (1 - X) * (1 - X) * dt;
  //float deltaX = k * (1 - X) * dt;   *First Order Kinetics
  
  // per-particle probability
  float P_react = numReactants > 0 ? deltaX * numParticles / numReactants : 0;
  P_react = constrain(P_react, 0, 1);
  
  // store progress for graph
  progressHistory.add(X);
  
  // update particles
  for (int i = 0; i < numParticles; i++) {
    particles[i].move();
    
    // collisions
    for (int j = i+1; j < numParticles; j++) {
      particles[i].checkCollision(particles[j], P_react);
    }
    
    particles[i].display();
  }
  
  drawGraph();
}

// Particle class
class Particle {
  float x, y;
  float vx, vy;
  float radius;
  int state; // 0 = reactant, 1 = product

  Particle(float x_, float y_) {
    x = x_;
    y = y_;
    vx = random(-2, 2);
    vy = random(-2, 2);
    radius = random(5, 15);
    state = 0;
  }

  void move() {
    x += vx;
    y += vy;
    if (x < radius || x > width - radius) vx *= -1;
    if (y < radius || y > height - radius) vy *= -1;
  }

  void checkCollision(Particle other, float P_react) {
    float d = dist(x, y, other.x, other.y);
    if (d < radius + other.radius) {
      // elastic collision
      float tempVx = vx;
      float tempVy = vy;
      vx = other.vx;
      vy = other.vy;
      other.vx = tempVx;
      other.vy = tempVy;
      
      // reaction based on kinetics
      if (state == 0 && other.state == 0 && random(1) < P_react){
        state = 1;
        other.state = 1;
      }
      //if (other.state == 0 && state ==0 && random(1) < P_react) other.state = 1; **First Order Kinetics
    }
  }

  void display() {
    if (state == 0) fill(255, 50, 50, 200);
    else fill(255, 255, 0, 200);
    noStroke();
    ellipse(x, y, radius*2, radius*2);
  }
}

// Draw graph with X and Y scaling
void drawGraph() {
  push();
  translate(10, 10);
  fill(50, 50, 50, 200);
  rect(0, 0, graphWidth, graphHeight);
  
  // y-axis: max fraction seen so far
  float maxY = 0;
  for (float val : progressHistory) if (val > maxY) maxY = val;
  if (maxY < 0.1) maxY = 0.1;
  
  // x-axis: scale full history to fit graph width
  stroke(255);
  noFill();
  beginShape();
  int n = progressHistory.size();
  for (int i = 0; i < n; i++) {
    float x = map(i, 0, n-1, 0, graphWidth); // full history fits
    float y = map(progressHistory.get(i), 0, maxY, graphHeight, 0);
    vertex(x, y);
  }
  endShape();
  
  fill(255);
  textSize(12);
  text("Reaction Progress (X)", 5, graphHeight + 15);
  text("Time →", graphWidth - 40, graphHeight + 15);
  pop();
}
