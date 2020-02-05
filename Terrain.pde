color cementColor, darkCementColor;

//////////////////////////////////////////////////////////////////////////////////
// PERLIN NOISE
//////////////////////////////////////////////////////////////////////////////////
int spacingTerr, colsTerr, rowsTerr;
float[][] terrain, groundTerrain, cloudTerrain;
float flyingTerr = 0;
float flyingTerrInc = 0.005;
boolean flyingTerrOn = true;
float xoffInc = 0.2;
boolean acceleratingTerr = true;
int lastCheckedTerr = 0;
boolean beginningTerrain = false;

int groundMin = -80;
int groundMax = 5;
int waterMin = 0;
int waterMax = 70;

int cloudMin = 0;
int cloudMax = 300;

float inc = 0;
float incAmt = 0.005;
PGraphics maskGraphics, tempGraphics;
float globalAngle = 55;

void initTerrain() {
  //int w = 1840; 
  //int h = 1400; 
  int w = int(width*3.5);
  int h = int(height*2);
  int spacing = 80;
  this.colsTerr = w/spacing;
  this.rowsTerr = h/spacing;
  this.spacingTerr = spacing;
  terrain = new float[colsTerr][rowsTerr];
  groundTerrain = new float[colsTerr][rowsTerr];
  cloudTerrain = new float[colsTerr][rowsTerr];
  initGroundTerrain();

  //maskGraphics = createGraphics(canvas.width, canvas.height);
  //tempGraphics = createGraphics(canvas.width, canvas.height);

  cementColor = color(180, 180, 160);
  darkCementColor = lerpColor(cementColor, color(0), .7);
}




void initGroundTerrain() {
  float yoff = flyingTerr;

  for (int y = 0; y < rowsTerr; y++) {
    float xoff = 0;
    for (int x = 0; x < colsTerr; x++) {
      //if (y > rowsTerr - 4) {
      //} else {
      groundTerrain[x][y] = map(noise(xoff, yoff), 0, 1, groundMin, groundMax);
      //}
      xoff += xoffInc;
    }
    yoff += xoffInc;
  }
}

void setGridTerrain() {
  //if (flyingTerrOn) 
  //flyingTerrInc = 0.01 *sin(millis()/1000.0);
  flyingTerr -= flyingTerrInc;

  float yoff = flyingTerr;

  for (int y = 0; y < rowsTerr; y++) {
    float xoff = 0;
    for (int x = 0; x < colsTerr; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, waterMin, waterMax);
      cloudTerrain[colsTerr - x - 1][rowsTerr - y - 1] =  map(noise(xoff, yoff), 0, 1, cloudMin, cloudMax);
      xoff += xoffInc;
    }
    yoff += xoffInc;
  }
  reduceWaterPlants();
}

void reduceWaterPlants() {
  if (TESTING) {
    for (Plant p : permPlants) {
      reduceWater(int(p.x), int(p.y), int(p.z), p.plantHeight);
    }
  } else {
    for (Plant p : spawnedPlants) {
      reduceWater(int(p.x), int(p.y), int(p.z), p.plantHeight);
    }
  }
}


int[] getRowCol(float x, float y, float z) {
  return getRowCol(int( x), int (y), int (z));
}

int[] getRowCol(int x, int y, int z) {
  PVector origin = getWaterOrigin();
  float dx = x - origin.x;
  float dy = y - origin.y;
  float dz = z - origin.z;
  float dhypo = sqrt(dz*dz + dy*dy);

  int[] rowcol = new int[2];
  rowcol[1] = round(dx / spacingTerr);
  //rowcol[1] = round(map(rowcol[1], 0, colsTerr, 2, colsTerr-3));
  rowcol[0] = round(dhypo/spacingTerr);
  return rowcol;
}


void reduceWater(float x, float y, float z, float plantH) {
  reduceWater(int( x), int (y), int (z), plantH);
}


void reduceWater(int x, int y, int z, float plantH) {
  int[] rowcol = getRowCol(x, y, z);
  /// so i messed this up b/c terrain is [x][y] which maybe should be [y][x]
  int r = rowcol[1];
  int c = rowcol[0];
  if (r >= 0 && c >= 0 && r < terrain.length && c < terrain[0].length) {
    if (TESTING) plantH = 1.0;
    float localMin = terrain[r][c]-100* plantH;
    int area = 5;
    float maxD = area/2.0 * sqrt(2);

    for (int startc = c-area/2; startc < c + area/2; startc++) {
      for (int startr = r-area/2; startr < r+area/2; startr++) {
        if (startc >= 0 && startc < terrain[0].length && startr < terrain.length && startr >= 0) {
          float temp = terrain[startr][startc];
          float dis = dist(c, r, startc, startr);
          float newVal = map(dis, 0, maxD, localMin, temp);
          terrain[startr][startc] = newVal;
        }
      }
    }
  }
}


float waterY = 0;
void waterOff() {
  waterY = -150;
}

void setWater() {
  incSpawnedFloat();
  float lowestSea = -150;
  float maxs = 30;

  // if num spawned should affect water
  //float maxSea = map(spawnedFloat, 0, MAX_SPAWNED, maxs, -120);
  //maxSea = constrain(maxSea, -100, maxs);
  float maxSea = maxs;
  if (isRaining) {

    waterY = map(millis() - lastRainTime, 0, rainLasts, lowestSea, maxSea);
    waterY = constrain(waterY, lowestSea, maxSea);
  } else {
    if (millis() - lastRainTime >  rainLasts+sunLasts*.3) {
      waterY = map(millis() - lastRainTime, rainLasts+sunLasts*.3, rainLasts+sunLasts*.7, maxSea, lowestSea);
      waterY = constrain(waterY, lowestSea, maxSea);
    }
  }
}



void displayGroundTerrainCement(PGraphics s) {
  s.pushMatrix();
  s.translate(s.width/2, s.height, 0);
  s.rotateX(radians(globalAngle));
  s.rotateZ(radians(0));
  //s.fill(155, 70);

  s.noStroke();
  s.strokeWeight(3);

  s.translate(-colsTerr*spacingTerr/2, -(rowsTerr-1)*spacingTerr);
  for (int y = 0; y < rowsTerr-1; y++) {

    s.beginShape(TRIANGLE_STRIP);
    //s.texture(cement);
    s.textureMode(IMAGE);
    s.textureWrap(REPEAT);
    for (int x = 0; x < colsTerr; x++) {
      int alpha = 255;
      int min = groundMin;
      int max = groundMax;
      s.fill(cementColor);
      s.fill(255);
      s.vertex(x * spacingTerr, y * spacingTerr, groundTerrain[x][y], x*spacingTerr, y*spacingTerr);
      s.vertex(x * spacingTerr, (y+1) * spacingTerr, groundTerrain[x][y+1], x*spacingTerr, (y+1)*spacingTerr);
    }
    s.endShape();
  }
  s.popMatrix();
}



void displayGroundTerrain(PGraphics s) {
  s.pushMatrix();
  s.translate(s.width/2, s.height, 0);
  s.rotateX(radians(globalAngle));
  s.rotateZ(radians(0));
  //s.fill(155, 70);

  s.noStroke();
  s.strokeWeight(3);

  s.translate(-colsTerr*spacingTerr/2, -(rowsTerr-1)*spacingTerr);
  for (int y = 0; y < rowsTerr-1; y++) {

    s.beginShape(TRIANGLE_STRIP);
    //s.texture(cement);
    s.textureMode(IMAGE);
    s.textureWrap(REPEAT);
    for (int x = 0; x < colsTerr; x++) {
      int alpha = 255;
      int min = groundMin;
      int max = groundMax;
      s.fill(cementColor);
      s.fill(getCementFill(groundTerrain[x][y], color(60), cementColor, min, max, x, y, alpha));
      s.vertex(x * spacingTerr, y * spacingTerr, groundTerrain[x][y], x*spacingTerr, y*spacingTerr);
      s.fill(getCementFill(groundTerrain[x][y+1], color(60), cementColor, min, max, x, y+1, alpha));
      s.vertex(x * spacingTerr, (y+1) * spacingTerr, groundTerrain[x][y+1], x*spacingTerr, (y+1)*spacingTerr);
    }
    s.endShape();
  }
  s.popMatrix();
}



color getCementFill(float h, color start, color end, int min, int max, int x, int y, int alpha) {
  float per = map(h, min, max, 0, 1);
  color newc = lerpColor(start, end, per);
  float yper = map(y, 0, 10, 1, 0);
  newc = lerpColor(newc, cementColor, yper);
  int xstart = 10;
  int xend = xstart + 12;
  if (x < xstart) newc = cementColor;
  float xper = map(x, xstart, xend, 1, 0);
  newc = lerpColor(newc, cementColor, xper);
  newc = color(red(newc), green(newc), blue(newc), alpha);
  return newc;
}

color getVertexHeight(float h, color start, color end, int min, int max, int alpha) {
  float per = map(h, min, max, 0, 1);
  //per = constrain(per, 0, 1);
  color newc = lerpColor(start, end, per);
  float a = alpha;
  if (per < 0) {
    per = constrain(per, -1, 0);
    a = map(per, -1, 0, 10, alpha);
  }
  newc = color(red(newc), green(newc), blue(newc), a);
  return newc;
}

float waterFactor = 8.0/10;

float getBackWater() {
  return cos(radians(90-globalAngle))*-rowsTerr*spacingTerr*waterFactor;
}
float getBackGround() {
  return cos(radians(90-globalAngle))*-groundTerrain[0].length*spacingTerr*waterFactor;
}


void displayWater(PGraphics s, int z) {

  s.pushMatrix();
  s.translate(s.width/2, s.height-30-waterY, 0);
  s.rotateX(radians(globalAngle));
  s.noFill();
  s.fill(255, 170);
  //s.stroke(0, 0, 255, 90);
  //s.stroke(#FF00EF, 0);
  s.noStroke();
  s.strokeWeight(1);

  s.translate(-colsTerr*spacingTerr/2, -rowsTerr*spacingTerr*waterFactor);
  //s.colorMode(HSB, 255);
  for (int y = 0; y < rowsTerr-1; y++) {
    s.beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < colsTerr; x++) {
      int alpha = 155;
      int min = waterMin;
      int max = waterMax;
      s.fill(getVertexHeight(terrain[x][y], color(0, 0, 255), color(0, 255, 255), min, max, alpha));
      //if (y %2 == 0) s.fill(y*5, 0, 0);
      //if (x %2 == 0) s.fill(255, x*5, 0);
      //if (y%10 == 0) s.fill(0);
      //if (x%10 == 0) s.fill(255);
      s.vertex(x * spacingTerr, y * spacingTerr, terrain[x][y]);
      s.fill(getVertexHeight(terrain[x][y+1], color(0, 0, 255), color(0, 255, 255), min, max, alpha));
      s.vertex(x * spacingTerr, (y+1) * spacingTerr, terrain[x][y+1]);
    }
    s.endShape();
  }
  s.popMatrix();
}

float getCloudAlphaFactor() {
  long timeP = millis() - lastRainTime;
  if (timeP < rainLasts*.7) {
    return 1;
  } else if (timeP < rainLasts) {
    return map(timeP, rainLasts*.7, rainLasts, 1.0, 0);
  } else if (timeP < rainLasts + sunLasts * .7) {
    return 0;
  }
  return map(timeP, rainLasts + sunLasts*.7, rainLasts+sunLasts, 0, 1.0);
}

void displayClouds(PGraphics s, int z) {
  s.pushMatrix();
  s.translate(s.width/2, 80, z);
  s.rotateX(radians(80));
  s.fill(255, 170);
  //s.stroke(0, 0, 255, 90);
  s.stroke(#FF00EF, 0);
  s.strokeWeight(1);

  s.translate(-colsTerr*spacingTerr/2, -rowsTerr*spacingTerr/2);
  //s.colorMode(HSB, 255);
  for (int y = 0; y < rowsTerr-1; y++) {
    s.beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < colsTerr; x++) {
      int alpha = int(155*getCloudAlphaFactor());
      int min = cloudMin;
      int max = cloudMax;
      s.fill(getVertexHeight(terrain[x][y], color(255), color(100), min, max, alpha));
      s.vertex(x * spacingTerr, y * spacingTerr, cloudTerrain[x][y]);
      s.fill(getVertexHeight(terrain[x][y+1], color(255), color(100), min, max, alpha));
      s.vertex(x * spacingTerr, (y+1) * spacingTerr, cloudTerrain[x][y+1]);
    }
    s.endShape();
  }
  s.popMatrix();
}
