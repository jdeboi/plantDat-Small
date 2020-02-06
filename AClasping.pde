PlantFile[] claspingLeaves;
PlantFile[] claspingFlowers;




void initClasping() {
  float[] claspingScalesF = {0.4, 0.4, 0.6};
  boolean[] claspingFlippedF = {false, false, false};
  float[] claspingRotF = {0, 0, 0};
  PVector[] claspingSnapsF = {new PVector(75, 100), new PVector(100, 100), new PVector(100, 120)};

  claspingFlowers = new PlantFile[3];
  for (int i = 0; i < claspingFlowers.length; i++) {
    claspingFlowers[i] = new PlantFile("clasping/flower/" + i + ".svg", claspingFlippedF[i], claspingSnapsF[i].x, claspingSnapsF[i].y, claspingScalesF[i], claspingRotF[i]);
  }

  float[] claspingScales = {0.6};
  boolean[] claspingFlipped = {false};
  float[] claspingRot = {radians(190)};
  PVector[] claspingSnaps = {new PVector(90, 140)};
  claspingLeaves = new PlantFile[1];
  for (int i = 0; i < claspingLeaves.length; i++) {
    claspingLeaves[i] = new PlantFile("clasping/leaves/" + i + ".svg", claspingFlipped[i], claspingSnaps[i].x, claspingSnaps[i].y, claspingScales[i], claspingRot[i]);
  }
}

class Clasping extends Plant {

   Clasping(PVector loc, float age, boolean dies) {
    this(loc, age, -1);
    this.dies = dies;
  }

  Clasping(PVector loc, float age, int code) {
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
    if (isFlowering) claspingFlowers[getStokesFlowerIndex(stemAge)].display(0, 0, 0, plantHeight, false, s);
  }

  void leaf(int segment, PGraphics s) {
    //s.pushMatrix();
    //s.translate(0, 0, 1);
    if (segment < 3 && segment > 0) {
      float scal = map(numBranch, 0, 15, 1.0, .3)*plantHeight;
      float leafScale = map(segment, 0, numSegments, 1.0, 0.4);
      claspingLeaves[0].display(0, 0, 0, scal*leafScale, false, s);
      //s.pushMatrix();
      //s.translate(0, -plantHeight*20);
      claspingLeaves[0].display(0, 0, 0, scal*leafScale, true, s);
      //s.popMatrix();
    }
    //s.popMatrix();
  }

  int getStokesFlowerIndex(float stemAge) {
    int num = int(map(stemAge, bloomAge, 1, 0, claspingFlowers.length));
    num = constrain(num, 0, claspingFlowers.length-1);
    return num;
  }

  int getStokesFlowerIndex() {
    int num = int(map(age, bloomAge, 1, 0, claspingFlowers.length));
    num = constrain(num, 0, claspingFlowers.length-1);
    return num;
  }


  void stem(PGraphics s, float plantH, float ang, float stemAge) {
    s.pushMatrix();
    //while (len > 2) {
      
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
      s.stroke(0);
      s.strokeWeight(1);
      s.beginShape(QUADS);
      s.fill(constrain(numBranch*40, 0, 255), 255, 0);
      //s.stroke(0);
      s.vertex(-sw/2, 0);
      s.vertex(sw/2, 0);
      s.vertex(sw/2, -len);
      s.vertex(-sw/2, -len);
      s.endShape(CLOSE);


      if (hasLeaves) {
        s.pushMatrix();
        s.translate(0, -len, 0.1);
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
}
