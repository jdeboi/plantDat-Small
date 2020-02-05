import java.util.*;
String url = "http://www.plantdat.com/";
ArrayList<Plant> spawnedPlants;
ArrayList<Plant> permPlants;
Map spawnedPlantIDs;
int lastSpawnCheck = 0;
float spawnedFloat = 0;
PShape shovel;

void initPermPlants() {
  permPlants = new ArrayList<Plant>();

  // middle
  //permPlants.add(new Clasping(getSpawnedXY(35, 0), 1.0, false));
  //permPlants.add(new Beauty(getSpawnedXY(36, 3), 1.0, false));
  //permPlants.add(new Lizard(getSpawnedXY(37, 0), 1.0, false));
}

void displaySpawned(PGraphics s) {
  for (int i = 0; i < spawnedPlants.size(); i++) {
    spawnedPlants.get(i).display(s);
    spawnedPlants.get(i).grow();
  }
}

void displayPermanent(PGraphics s) {
  for (int i = 0; i < permPlants.size(); i++) {
    permPlants.get(i).display(s);
    permPlants.get(i).grow();
  }
}

//long lastPlantRemoval = 0;
void removeDeadPlants() {
  //if (millis() - lastPlantRemoval > delay) {
  //lastPlantRemoval = millis();
  int i = 0;
  while (i < spawnedPlants.size()) {
    if (!spawnedPlants.get(i).alive) {
      //int code = spawnedPlants.get(i).id;
      spawnedPlants.remove(i);
      //println("removed old plant");
      // can forsee an issue where time delay means plant will respawn, flash, based on timing differences of web app and this program
      //spawnedPlantIDs.remove(code);
    } else {
      i++;
    }
  }
  //}
}



void incSpawnedFloat() {
  int spz = spawnedPlants.size();
  if (spawnedFloat < spz) {
    spawnedFloat += 0.01;
  } else if (spawnedFloat > spz) {
    spawnedFloat -= 0.01;
  }
}

void initSpawned() {
  spawnedPlants = new ArrayList<Plant>();
  spawnedPlantIDs = new HashMap();
  checkForSpawned(0);
  shovel = loadShape("images/shovel.svg");
}

void  checkForSpawned(int delayT) {
  if (millis() - lastSpawnCheck > delayT) {
    thread("requestData");
    lastSpawnCheck = millis();
  }
}

// This happens as a separate thread and can take as long as it wants
void requestData() {
  JSONArray sp = loadJSONArray(url + "api/allspawned");
  for (int i = 0; i < sp.size(); i++) {
    JSONObject pObj = sp.getJSONObject(i); 
    JSONObject plant = pObj.getJSONObject("plant");
    int code = plant.getInt("code");
    if (!spawnedPlantIDs.containsKey(code)) {
      if (breaking) {
        incrementBreaking();
      } else {
        addNewPlant(pObj, code);
      }
      spawnedPlantIDs.put(code, 1);
    } else {
      //println(code, " already exists");
    }
  }
}

void addNewPlant(JSONObject pObj, int code) {

  float age = pObj.getFloat("age");
  //age = constrain(age, 0, 1);
  JSONObject plant = pObj.getJSONObject("plant");
  String name = plant.getString("plantType"); 
  int x = plant.getInt("x");
  int y = plant.getInt("y");
  PVector xy = getSpawnedXY(x, y);

  if (name.equals("Lizard's Tail")) {
    spawnedPlants.add(new Lizard(xy, age, code));
    println("added new plant", name);
  } else if (name.equals("American Beautyberry")) {
    println("asd");
    spawnedPlants.add(new Beauty(xy, age, code));
    println("added new plant", name);
  } else if (name.equals("Clasping Cone Flower")) {
    spawnedPlants.add(new Clasping(xy, age, code));
    println("added new plant", name);
  } else if (name.equals("Correll’s Obedient Plant")) {
    spawnedPlants.add(new Obedient(xy, age, code));
    println("added new plant", name);
  } else if (name.equals("Stokes Aster")) {
    spawnedPlants.add(new Stokes(xy, age, code));
    println("added new plant", name);
  }

  println("Num spawned plants: ", spawnedPlants.size());
}

void displaySpawnedPlants(PGraphics s) {

  if (spawnedPlants != null) {

    for (int i = 0; i < spawnedPlants.size(); i++) {
      try {
        spawnedPlants.get(i).display(s);
      }
      catch(Exception e) {
        println(e);
        println("spawned plants is an issue...");
      }
    }
  }
}


// remeber that y is zero at the top of the screen...
PVector getSpawnedXY(float x, float y) {
  float zMin = getBackWater();
  float zMax = -50;
  float newZ = map(y, 0, 100, zMin, zMax);
  float newY =  map(y, 100, 0, canvas.height+10, 100);
  float newX = map(x, 0, 100, newZ*.5, canvas.width-newZ*.5);
  return new PVector(newX, newY, newZ);
}

float getSpawnedY(float z) {
  float zMin = getBackWater();
  float zMax = -50;
  float newY =  map(z, zMax, zMin, canvas.height+10, 200);
  return newY;
}

PVector getWaterOrigin() {
  float x = canvas.width/2-colsTerr*spacingTerr/2;

  //float y = canvas.height-30-waterY;
  float z = getBackWater();
  float y = getSpawnedY(z);
  return new PVector(x, y, z);
}


void spawnFakePlants() {
  for (int x = 0; x <= 100; x += 25) {
    for (int y = 0; y <= 100; y+= 25) {
      PVector temp = getSpawnedXY(x, y);
      //int i = int(random(5));
      //if (i == 0) permPlants.add(new Stokes(temp, 0, -1));
      //else if (i == 1) permPlants.add(new Lizard(temp, 0, -1));
      //else if (i == 2) permPlants.add(new Beauty(temp, 0, -1));
      //else if (i == 3) permPlants.add(new Clasping(temp, 0, -1));
      //else if (i == 4) permPlants.add(new Obedient(temp, 0, -1));
      permPlants.add(new Button(temp, 0, -1));
    }
  }
}

long recurringPlantTime = 0;
void spawnRecurringPlants(int delayt) {
  randomSeed(millis());
  int i = int(random(10));
  if (millis() - recurringPlantTime > delayt) {
    recurringPlantTime = millis();
    if (i == 0) spawnedPlants.add(new Stokes(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 1) spawnedPlants.add(new Lizard(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 2) spawnedPlants.add(new Beauty(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 3) spawnedPlants.add(new Clasping(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 4) spawnedPlants.add(new Obedient(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 5) spawnedPlants.add(new Blueeye(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 6) spawnedPlants.add(new Sleeping(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 7) spawnedPlants.add(new Frog(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 8) spawnedPlants.add(new Rose(getSpawnedXY(random(100), random(100)), 0, -1));
    else if (i == 9) spawnedPlants.add(new Button(getSpawnedXY(random(100), random(100)), 0, -1));
  }
}

void displayBoundaries(PGraphics s) {
  PVector temp;
  for (int x = 0; x <= 100; x += 25) {
    for (int y = 0; y <= 100; y+= 25) {
      temp = getSpawnedXY(x, y);
      s.pushMatrix();
      s.fill(255, 0, y*100);
      s.translate(temp.x, temp.y, temp.z);
      reduceWater(temp.x, temp.y, temp.z, 1.0);
      s.ellipse(0, 0, 30, 30);
      s.popMatrix();
    }
  }
}
