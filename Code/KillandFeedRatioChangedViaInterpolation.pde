float[][] A;
float[][] B;
float[][] Anext;
float[][] Bnext;
float d1 = 1;
float d2 = 0.5;
float dt = 0.5; // smaller for stability
int scale = 2;
int rows, columns;

void setup(){
  size(800,1000);
  rows = height/scale;
  columns = width/scale;
  
  A = new float[rows][columns];
  B = new float[rows][columns];
  Anext = new float[rows][columns];
  Bnext = new float[rows][columns];
  
  //Randomly Seed pockets of B
  for(int r = 0; r < rows; r++){
    for(int c = 0; c < columns; c++){
      A[r][c] = 1;
      B[r][c] = 0;
      Anext[r][c] = 0;
      Bnext[r][c] = 0;
      if(random(100) < 5){
        A[r][c] = 0;
        B[r][c] = 1;
      }
    }
  }
}

void draw(){
  for(int r = 0; r < rows; r++){
    for(int c = 0; c < columns; c++){  
      fill(A[r][c]*200, B[r][c]*255, 175);
      rect(c*scale, r*scale, scale, scale);
    }
  }
  update();
}

void update(){
  for(int r = 0; r < rows; r++){
    for(int c = 0; c < columns; c++){  
      // Compute spatially varying feed and kill rates via interpolation
      float localF = map(r, 0, rows-1, 0.045, 0.07); // feed varies along y
      float localK = map(c, 0, columns-1, 0.04, 0.1); // kill varies along x

      // Update A based on Eulers
      Anext[r][c] = A[r][c];
      // Diffusion neighbors
      Anext[r][c] += (A[wrap(r-1,rows)][wrap(c-1,columns)]
                     + A[wrap(r+1,rows)][wrap(c+1,columns)]
                     + A[wrap(r+1,rows)][wrap(c-1,columns)]
                     + A[wrap(r-1,rows)][wrap(c+1,columns)]) * d1 * 0.05 * dt;
      Anext[r][c] += (A[wrap(r-1,rows)][wrap(c,columns)]
                     + A[wrap(r+1,rows)][wrap(c,columns)]
                     + A[wrap(r,rows)][wrap(c-1,columns)]
                     + A[wrap(r,rows)][wrap(c+1,columns)]) * d1 * 0.2 * dt;
      Anext[r][c] += -A[r][c] * d1 * dt;
      // Reaction
      Anext[r][c] -= A[r][c] * B[r][c] * B[r][c] * dt;
      // Feed
      Anext[r][c] += localF * (1 - A[r][c]) * dt;

      //Update B based on Eulers
      Bnext[r][c] = B[r][c];
      // Diffusion neighbors
      Bnext[r][c] += (B[wrap(r-1,rows)][wrap(c-1,columns)]
                     + B[wrap(r+1,rows)][wrap(c+1,columns)]
                     + B[wrap(r+1,rows)][wrap(c-1,columns)]
                     + B[wrap(r-1,rows)][wrap(c+1,columns)]) * d2 * 0.05 * dt;
      Bnext[r][c] += (B[wrap(r-1,rows)][wrap(c,columns)]
                     + B[wrap(r+1,rows)][wrap(c,columns)]
                     + B[wrap(r,rows)][wrap(c-1,columns)]
                     + B[wrap(r,rows)][wrap(c+1,columns)]) * d2 * 0.2 * dt;
      Bnext[r][c] += -B[r][c] * d2 * dt;
      // Reaction
      Bnext[r][c] += A[r][c] * B[r][c] * B[r][c] * dt;
      // Kill
      Bnext[r][c] -= (localK + localF) * B[r][c] * dt;

      // Clamp values to prevent black screen
      Anext[r][c] = constrain(Anext[r][c], 0, 1);
      Bnext[r][c] = constrain(Bnext[r][c], 0, 1);
    }
  }

  // // Implement the calculated changes to the cells
  for(int r = 0; r < rows; r++){
    for(int c = 0; c < columns; c++){
      A[r][c] = Anext[r][c];
      B[r][c] = Bnext[r][c];
    }
  }

  noStroke();
}

// Wrap edges for periodic boundary
int wrap(int v, int limit){
  return (v + limit) % limit;
}
