
PlantFile[] blueeyeFlowers;

void initBlueeye() {
  float[] blueeyeScalesF = {0.18, 0.2, 0.22,  0.22, .28}; //, 0.3,
  boolean[] blueeyeFlippedF = {false, false, false, false, false, false};
  float[] blueeyeRotF = {0, 0, 0, 0, 0, 0};
  PVector[] blueeyeSnapsF = {new PVector(120, 180), new PVector(180, 200), new PVector(310, 180), new PVector(150, 380), new PVector(300, 220)}; //new PVector(340, 240),

  blueeyeFlowers = new PlantFile[5];
  for (int i = 0; i < blueeyeFlowers.length; i++) {
    blueeyeFlowers[i] = new PlantFile("blueeye/flower/" + i + ".svg", blueeyeFlippedF[i], blueeyeSnapsF[i].x, blueeyeSnapsF[i].y, blueeyeScalesF[i]*.55, blueeyeRotF[i]);
  }
}

class Blueeye extends Plant {

  Blueeye(PVector loc, float age, boolean dies) {
    this(loc, age, -1);
    this.dies = dies;
  }

  Blueeye(PVector loc, float age, int code) {
    super(loc, age, code);
    //leaves = new ArrayList<BeautyLeaf>();
    growthScaler = 200*.55;
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

    // flowering
    stem(s, plantHeight*growthScaler, 0, age, false, pID%2 == 0);
    // possibly flowering
    int neg = pID%3==0?1:-1;
    boolean isLeaf = (pID+1)%4 != 0;
    stem(s, plantHeight*growthScaler*.7, radians(10*neg), age, isLeaf, neg==1?true:false);


    // pure leaves
    neg = pID%2==0?1:-1;
    stem(s, plantHeight*growthScaler*.9, radians(-8), age, pID%4 != 0, true);
    stem(s, plantHeight*growthScaler*.85, radians(-4), age, true, false);
    stem(s, plantHeight*growthScaler*.3, radians(-24 * neg), age, true, true);
    stem(s, plantHeight*growthScaler*.4, radians(23* neg), age, true, false);

    s.popMatrix();
  }

  void flower(PGraphics s, float stemAge, boolean isLeft) {
    if (stemAge > bloomAge) isFlowering = true;
    else isFlowering = false;
    isFlowering = true;
    int num =   millis()/5000%blueeyeFlowers.length; //getBlueeyeIndex(stemAge);
    if (isFlowering) {
      if (num > 2) blueeyeFlowers[2].display(0, 0,0, plantHeight, isLeft, s); 
      float r = 0;
      if (num == 3) r = radians(-65);
      blueeyeFlowers[num].display(0, 0, r, plantHeight, isLeft, s); //pID%2 ==0
    }
  }

  void leaf(int segment, PGraphics s) {
  }

  int getBlueeyeIndex(float stemAge) {
    int num = int(map(stemAge, bloomAge, 1, 0, blueeyeFlowers.length));
    num = constrain(num, 0, blueeyeFlowers.length-1);
    return num;
  }


  void stem(PGraphics s, float plantH, float ang, float stemAge, boolean isLeaf, boolean isLeft) {
    s.pushMatrix();
    //while (len > 2) {

    float len = 1.3* plantH / numSegments; 
    s.translate(0, len);
    for (int i = 0; i < numSegments; i++) {

      //s.pushMatrix();  
      s.translate(0, -len);
      //len *= 0.66;
      float angle = curveAngle + windAngle + ang;
      angle = constrain(angle, -PI/7, PI/7);
      s.rotate(angle);   
      float sw = map(i, 0, numSegments, 10, 1)*plantHeight;
      sw = constrain(sw, 1, 10);
      color c = lerpColor(color(0, 120, 0), color(0, 80, 0), map(i, 0, numSegments, 0, 1)); 
      s.stroke(0, 80, 0);
      s.strokeWeight(1);
      s.beginShape(QUADS);
      s.fill(c);
      //s.stroke(0);
      s.vertex(-sw/2, 0);
      s.vertex(sw/2, 0);
      s.vertex(sw/2, -len);
      s.vertex(-sw/2, -len);
      s.endShape(CLOSE);
    }
    if (isFlowering && !isLeaf) {
      s.translate(0, -len);
      s.pushMatrix();
      s.translate(0, 0, 3);
      flower(s, stemAge, !isLeft);
      s.popMatrix();
    }
    s.popMatrix();
  }
}
