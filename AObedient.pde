PlantFile[] obedientLeaves;
PlantFile[] obedientFlowers;

void initObedient() {
  float[] obedientScales = {0.4, 0.3};
  boolean[] obedientFlipped = {false, false};
  float[] obedientRot = {0, 0};
  PVector[] obedientSnaps = {new PVector(25, 142), new PVector(60, 300)};

  obedientFlowers = new PlantFile[2];
  for (int i = 0; i < obedientFlowers.length; i++) {
    obedientFlowers[i] = new PlantFile("obedient/flower/" + i + ".svg", obedientFlipped[i], obedientSnaps[i].x, obedientSnaps[i].y, obedientScales[i], obedientRot[i]);
  }

  float[] obedientScalesL = {0.3};
  boolean[] obedientFlippedL = {false};
  float[] obedientRotL = {radians(0)};
  PVector[] obedientSnapsL = {new PVector(250, 60)};

  obedientLeaves = new PlantFile[1];
  for (int i = 0; i < obedientLeaves.length; i++) {
    obedientLeaves[i] = new PlantFile("obedient/leaves/" + i + ".svg", obedientFlippedL[i], obedientSnapsL[i].x, obedientSnapsL[i].y, obedientScalesL[i], obedientRotL[i]);
  }
}

class Obedient extends Plant {

  Obedient(PVector loc, float age, boolean dies) {
    this(loc, age, -1);
    this.dies = dies;
  }

  Obedient(PVector loc, float age, int code) {
    super(loc, age, code);
    //leaves = new ArrayList<BeautyLeaf>();
    growthScaler = 200;
    branching = false;
    hasLeaves = true;

    //numBranches = int(random(0, 3));
    //branchDeg = random(8, 15);
    //if (Math.random() > -0.5) branchDeg *= -1;
  }

  void display(PGraphics s) {
    //s.stroke(col);
    s.pushMatrix();
    s.translate(x, y, z);
    //s.rotateX(radians(25));
    float angle = stemAngle + windAngle/3.0;
    angle = constrain(angle, -10, 10);
    s.rotate(angle);

    numBranch = 0;
    totLen = leafSpacing;
    currentLen = leafSpacing;

    stem(s, plantHeight*growthScaler, 0, age);

    s.popMatrix();
  }

  void flower(PGraphics s, float stemAge) {
    if (stemAge > bloomAge) isFlowering = true;
    else isFlowering = false;
    isFlowering = true;
    if (isFlowering) obedientFlowers[getFlowerIndex(stemAge)].display(0, 0, 0, plantHeight, false, s);
  }

  void leaf(int segment, PGraphics s) {
    float scal = map(numBranch, 0, 15, 1.0, .3)*plantHeight;
    float leafScale = map(segment, 0, numSegments, 1.0, 0.4);
    if (segment > 0) {
      obedientLeaves[0].display(0, 0, 0, scal*leafScale, false, s);
    }
    if (segment < 4) {
      s.pushMatrix();
      s.translate(0, -plantHeight*20);
      obedientLeaves[0].display(0, 0, 0, scal*leafScale, true, s);
      s.popMatrix();
    }
  }

  int getFlowerIndex(float stemAge) {
    int num = int(map(stemAge, bloomAge, 1, 0, obedientFlowers.length));
    num = constrain(num, 0, obedientFlowers.length-1);
    return num;
  }


  void stem(PGraphics s, float plantH, float ang, float stemAge) {
    s.pushMatrix();
    s.strokeWeight(1);
    //while (len > 2) {
    float len = 1.0* plantH / numSegments; 
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
      s.stroke(getStemStroke());
      s.beginShape(QUADS);
      s.fill(getStemFill(numBranch));
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
        s.translate(0, -len);
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
  
  color getStemStroke() {
    return 0;
  }

  color getStemFill(int numBranch) {
    return color(constrain(numBranch*40, 0, 255), 255, 0);
  }
}
