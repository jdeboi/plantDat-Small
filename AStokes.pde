PlantFile[] stokesFlowers;
PlantFile stokesLeaf;



void initStokes() {  
  stokesFlowers = new PlantFile[4];
  float[] stokesScales = {0.5, 0.7, .6, .6};
  boolean[] stokesFlipped = {false, false, false, false};
  float[] stokesRot = {0, 0, 0, 0};
  PVector[] stokesSnaps = {new PVector(24, 35), new PVector(53, 81), new PVector(75, 85), new PVector(95, 105)};
  stokesLeaf = new PlantFile("stokes/leaves/0.svg", false, 4, 131, 0.6, 0);
  for (int i = 0; i < stokesFlowers.length; i++) {
    stokesFlowers[i] = new PlantFile("stokes/flower/" + i + ".svg", stokesFlipped[i], stokesSnaps[i].x, stokesSnaps[i].y, stokesScales[i], stokesRot[i]);
  }
}


class Stokes extends Plant {

  int numBranches;
  float branchDeg;

  Stokes(PVector loc, float age, boolean dies) {
    this(loc, age, -1);
    this.dies = dies;
  }

  Stokes(PVector loc, float age, int code) {
    super(loc, age, code);
    //leaves = new ArrayList<BeautyLeaf>();
    growthScaler = 200;
    branching = true;
    isFlowering = true;
    hasLeaves = true;

    numBranches = int(random(0, 3));
    branchDeg = random(8, 15);
    if (Math.random() > -0.5) branchDeg *= -1;
    col = color(#4EBD00);
  }

  void display(PGraphics s) {
    //s.stroke(col);
    s.pushMatrix();
    s.translate(x, y, z);
    float angle = stemAngle + windAngle/3.0;
    angle = constrain(angle, -10, 10);
    s.rotate(angle);

    numBranch = 0;
    totLen = leafSpacing;
    currentLen = leafSpacing;

    s.stroke(0);
    s.fill(col);
    stem(s, plantHeight*growthScaler, 0, age, stemStroke);

    s.popMatrix();
  }

  void flower(PGraphics s, float stemAge) {
    s.pushMatrix();
    s.translate(0, 0, 1);
    if (stemAge > bloomAge) isFlowering = true;
    else isFlowering = false;
    isFlowering = true;
    //s.translate(0, 0, 5);
    if (isFlowering) displayFlower(stemAge, s);
    s.popMatrix();
  }
  
  void displayFlower(float stemAge, PGraphics s) {
    stokesFlowers[getFlowerIndex(stemAge)].display(0, 0, 0, plantHeight, false, s);
  }

  void leaf(int segment, PGraphics s) {
    //super.leaf(segment, s);
    s.pushMatrix();
    s.translate(0, 0, (5-segment));
    float leafScale = map(segment, 0, 5, .7, 0.1);
    if (numBranch == 1) {
      stokesLeaf.display(0, 0, 0, plantHeight*leafScale, false, s);
    } else if (numBranch % 5 == 3) {
      //float scal = map(numBranch, 0, 15, 1.0, .25)*plantHeight;
      stokesLeaf.display(0, 0, 0, plantHeight*leafScale, true, s);
    } else if (numBranch % 5 == 4) {
      //float scal = map(numBranch, 0, 15, 1.0, .2)*plantHeight;
      stokesLeaf.display(0, 0, 0, plantHeight*leafScale, false, s);
    } 
    s.popMatrix();
  }

  int getFlowerIndex(float stemAge) {
    int num = int(map(stemAge, bloomAge, 1, 0, 4));
    num = constrain(num, 0, 3);
    return num;
  }

  @Override 
    void branchOut(PGraphics s, float stemAge) {
    if (numBranches > 0) {
      if (numBranch == 2) {
        stem(s, plantHeight*growthScaler/2, radians(branchDeg), stemAge*.8, stemStroke);
      }
    } 
    if (numBranches > 1) {
      if (numBranch == 3) {
        stem(s, plantHeight*growthScaler/4, radians(-branchDeg), stemAge*.5, stemStroke);
      }
    }
  }
}
