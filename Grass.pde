Grasses grasses;
int GRASS_ID = 0;

void initGrasses() {
  grasses = new Grasses(-canvas.width/2, canvas.height, 150, canvas.width*2);
}

void displayGrass(PGraphics s, Grasses g) {
  g.display(s);
}

class Grasses {

  ArrayList<GrassBlade>grasses;
  int id;
  Grasses(int x, int y, int num, int w) {
    id = 0;
    grasses = new ArrayList<GrassBlade>();
    for (int i = 0; i < num; i++) {
      PVector loc = getSpawnedXY(random(100), random(100));
      grasses.add(new GrassBlade(int(loc.x), int(loc.y), int(loc.z)));
    }
  }

  void display(PGraphics s) {
    for (int i = 0; i < grasses.size(); i++) {
      grasses.get(i).display(s);
    }
  }

  void grow() {
    for (GrassBlade g : grasses) {
      g.grow();
    }
  }
}

class GrassBlade extends Plant {

  float curveAngle;
  float stemAngle;
  color col;
  int id;
  int numBranch = 0;

  GrassBlade(int x, int y, int z) {
    super(x, y, z);
    id = GRASS_ID++;
    growthScaler = random(100, 140);
    branching = false;
    hasLeaves = false;
    respawns = true;
    dies = false;
    col = color(0, random(150, 255), 0);
  }


  void display(PGraphics s) {
    s.pushMatrix();
    s.translate(x, y, z);
    //s.rotateX(radians((-groundRot)));
    float angle = stemAngle + windAngle/3.0;
    angle = constrain(angle, -10, 10);
    s.rotate(angle);

    numBranch = 0;
    stem(s, plantHeight*growthScaler*.8, radians(-8), age, stemStroke);
    numBranch = 0;
    if (id %2 == 0) stem(s, plantHeight*growthScaler, 0, age, stemStroke);
    numBranch = 0;
    if (id %3 == 0) stem(s, plantHeight*growthScaler*.6, radians(6), age, stemStroke);
    s.popMatrix();
  }
  
  void flower(PGraphics s, float stemAge) {
    // nada
  }
  
  void stem(PGraphics s, float plantH, float ang, float stemAge, color stCol) {
    s.pushMatrix();
    float len = 1.0* plantH / numSegments; 
    for (int i = 0; i < numSegments; i++) {
      numBranch++;

      //s.pushMatrix();  
      s.translate(0, -len);
      //len *= 0.66;
      float angle = curveAngle + windAngle + ang;
      angle = constrain(angle, -PI/7, PI/7);
      s.rotate(angle);   
      float sw = map(i, 0, numSegments, 6, 1)*plantHeight;
      sw = constrain(sw, .5, 3);
      //s.noStroke();
      //s.stroke(stCol);
      //s.strokeWeight(1);
      s.noStroke();
      float per = map(numBranch, 0, numSegments, 0, 1);
      per = constrain(per, 0, 1);
      s.fill(lerpColor(col, color(255, 255, 0), per ));
      //s.fill(col);
      s.beginShape(QUADS);
      //s.fill(constrain(numBranch*40, 0, 255), 255, 0);
      //s.stroke(0);
      s.vertex(-sw/2, 0);
      s.vertex(sw/2, 0);
      s.vertex(sw/2, -len);
      s.vertex(-sw/2, -len);
      s.endShape(CLOSE);

    }
    s.popMatrix();
  }
}
