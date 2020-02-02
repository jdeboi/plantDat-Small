int lifeTimeSeconds = 1*10; // 3 minutes
int lifeTimeFrames = lifeTimeSeconds*60; // 60 frames / second 
float ageInc = 1.0/lifeTimeFrames;
int plantID = 0;
color plantColor;
color stemStroke;

class Plant {


  int x, y, z, id, pID;

  // age
  float age = 0;
  float ageDeath;
  float ageGrowthStops = 0.8;
  float  bloomAge = 0.5;
  boolean dies = true;
  boolean alive = true;
  boolean respawns = false;

  // growth and height
  float growthRate;
  float plantHeight = 0;
  float growthScaler = 200;
  int numSegments = 5;
  float totLen = 0;
  float currentLen = 0;

  float curveAngle, stemAngle;
  int numBranch = 0;

  boolean hasLeaves = false;
  int leafSpacing = 30;
  boolean isFlowering = false;
  boolean branching = false;

  color col;


  // randomish noise
  float yoff = 0;
  int seed;


  public Plant(PVector loc, float age, boolean dies) {
    this(int(loc.x), int(loc.y), int(loc.z), age, -1);
    this.dies = dies;
  }

  public Plant(PVector loc, float age, int code) {
    this(int(loc.x), int(loc.y), int(loc.z), age, code);
  }

  public Plant (int x, int y, int z) {
    this(x, y, z, 0, -1);
  }

  public Plant (int x, int y, int z, float age, int code) {
    this.x = x;
    this.y = y;
    this.z = z;
    ageDeath = random(2.0, 3.0);
    growthRate = random(ageInc - ageInc*.2, ageInc + ageInc * .2);
    curveAngle = radians(random(-10, 10));
    stemAngle = radians(random(-5, 5));

    id = code;
    pID = plantID++;
    if (code  < 0) seed = int(random(0, 100));
    col = color(0, random(150, 255), 0);
    // maybe everything should just start at 0
    //this.age = age;
    //this.plantHeight = age;
  }


  public void display(PGraphics s) {
    //s.stroke(col);
    s.pushMatrix();
    s.translate(x, y, z);
    float angle = stemAngle + windAngle/3.0;
    angle = constrain(angle, -10, 10);
    s.rotate(angle);

    numBranch = 0;
    totLen = leafSpacing;
    currentLen = leafSpacing;

    branch(s, plantHeight*100);

    s.popMatrix();
  }

  public void getOlder() {
    if (age < ageDeath) {
      age += ageInc;
    } else {
      if (respawns) respawn();
      else if (dies) alive = false;
    }
  }

  public void grow() {
    getOlder();
    if (age > bloomAge) {
      isFlowering = true;
    }
    if (age < ageGrowthStops) {
      plantHeight += growthRate;
    }
  }

  void respawn() {
    age = 0;
    plantHeight = 0;
  }


  void branch(PGraphics s, float len) {
    // Each branch will be 2/3rds the size of the previous one
    float sw = map(len, 2, 120, 1, 10);
    //s.strokeWeight(sw);
    //s.noStroke();
    //s.line(0, 0, 0, -len);
    //s.fill(col);
    //s.rect(0, 0, sw, -len);
    s.beginShape(QUADS);
    //s.fill(constrain(numBranch*40, 0, 255), 255, 0);
    s.vertex(0, 0);
    s.vertex(sw, 0);
    s.vertex(sw, -len);
    s.vertex(0, -len);
    s.endShape(CLOSE);


    //Move to the end of that line
    s.translate(0, -len);

    len *= 0.66;
    // All recursive functions must have an exit condition!!!!
    // Here, ours is when the length of the branch is 2 pixels or less
    if (len > 2) {
      s.pushMatrix();    // Save the current state of transformation (i.e. where are we now)
      float angle = curveAngle + windAngle;
      angle = constrain(angle, -PI/7, PI/7);
      s.rotate(angle);   
      branch(s, len);       // Ok, now call myself to draw two new branches!!
      s.popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    }
  }

  void stem(PGraphics s, float plantH, float ang, float stemAge, color stCol) {
    s.pushMatrix();

    float len = 1.0* plantH / numSegments; 
    s.translate(0, len);
    for (int i = 0; i < numSegments; i++) {
      numBranch++;

      //s.pushMatrix();  
      s.translate(0, -len);
      //len *= 0.66;
      float angle = curveAngle + windAngle + ang;
      angle = constrain(angle, -PI/7, PI/7);
      s.rotate(angle);   
      float sw = map(i, 0, numSegments, 10, 1)*plantHeight;
      sw = constrain(sw, 1, 10);
      //s.noStroke();
      s.stroke(stCol);
      s.strokeWeight(1);
      float per = map(numBranch, 0, numSegments, 0, .5);
      per = constrain(per, 0, 1);
      s.fill(lerpColor(col, color(255, 255, 0), per ));
      s.fill(col);
      s.beginShape(QUADS);
      //s.fill(constrain(numBranch*40, 0, 255), 255, 0);
      //s.stroke(0);
      s.vertex(-sw/2, 0);
      s.vertex(sw/2, 0);
      s.vertex(sw/2, -len);
      s.vertex(-sw/2, -len);
      s.endShape(CLOSE);

      if (branching) {
        branchOut(s, stemAge);
      }
      if (hasLeaves) {
        s.pushMatrix();
        s.translate(0, -len, 0.2);
        leaf(i, s);
        s.popMatrix();
      }
    }
    if (isFlowering) {
      s.translate(0, -len);
      flower(s, stemAge);
    }
    s.popMatrix();
  }


  void leaf(float h, PGraphics s) {
    //s.ellipse(-50, 0, 100, 10);
    //s.ellipse(50, 0, 100, 10);
    s.fill(0);
    s.text(h, 0, 0);
  }

  void leaf(int segment, PGraphics s) {
    //s.ellipse(-50, 0, 100, 10);
    //s.ellipse(50, 0, 100, 10);
    s.fill(0);
    s.text(segment, 0, 0);
  }

  void flower(PGraphics s, float stemAge) {
    s.fill (255, 0, 0);
    s.ellipse(0, 0, 50*stemAge, 50*stemAge);
  }

  void branchOut(PGraphics s, float stemAge) {
    //if (numBranch == 2) {
    //  stem(s, plantHeight*growthScaler/2, radians(15), stemAge*.8);
    //}
    //else if (numBranch == 3) {
    //  stem(s, plantHeight*growthScaler/4, radians(-15), stemAge*.5);
    //}
  }
}

public class PlantFile {

  PShape img;
  boolean isFlipped;
  int snapX, snapY;
  float sc;
  float radRot;

  PlantFile(String path, boolean isFlipped, float snapx, float snapy, float sc, float rad) {
    img = loadShape("plants/" + path);
    this.isFlipped = isFlipped;
    this.snapX = int(snapx);
    this.snapY = int(snapy);
    this.sc = sc;
    this.radRot = rad;
  }

  void display(float _x, float _y, float _r, float _sc, boolean _isF, PGraphics s) {
    //img.disableStyle();
    s.pushMatrix();

    boolean f = false;
    if (isFlipped == _isF) {
      f = false;
    } else f = true;
    if (f) {
      s.scale(-1, 1);
    }
    s.translate(_x, _y);

    s.scale(sc*_sc);

    //float n = radians(10)*noise(num*50+millis()/1000.0);

    s.rotate(radRot+_r);
    s.translate(-snapX, -snapY);

    s.shape(img, 0, 0);

    s.popMatrix();
  }
}
