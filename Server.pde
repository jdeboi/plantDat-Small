int port = 8888; // 843 flash policy port

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;
//import java.util.Collection;
import java.util.*;
import org.java_websocket.WebSocket;
import org.java_websocket.WebSocketImpl;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

Map<WebSocket, ClientLoc> clientLocations;
PlantServer server;


void initServer() {
  clientLocations = new HashMap<WebSocket, ClientLoc>();
  new ServerThread().start();
}


void displayLiveSpawn(PGraphics s) {
  if (server != null) {
    Set< Map.Entry<WebSocket, ClientLoc>> st = clientLocations.entrySet(); 
    for (Map.Entry<WebSocket, ClientLoc> c : st) {
      c.getValue().display(s);
    }
  }
}


public class PlantServer extends WebSocketServer {

  public PlantServer( int port ) throws UnknownHostException {
    super( new InetSocketAddress( port ) );
  }

  public PlantServer( InetSocketAddress address ) {
    super( address );
  }

  @Override
    public void onOpen( WebSocket conn, ClientHandshake handshake ) {
    //this.sendToAll( "new connection: " +  handshake.getResourceDescrtiptor() );
    System.out.println( conn + " entered the room!" );
    clientLocations.put(conn, new ClientLoc());
  }

  @Override
    public void onClose( WebSocket conn, int code, String reason, boolean remote ) {
    //this.sendToAll( conn + " has left the room!" );
    System.out.println( conn + " has left the room!" );
    clientLocations.remove(conn);
  }

  @Override
    public void onMessage( WebSocket conn, String message ) {
    //this.sendToAll( message );
    System.out.println( conn + ": " + message );
    ClientLoc c = clientLocations.get(conn);
    c.update(message);
  }

  @Override
    public void onError( WebSocket conn, Exception ex ) {
    ex.printStackTrace();
    if ( conn != null ) {
      // some errors like port binding failed may not be assignable to a specific websocket
    }
  }

  /**
   * Sends <var>text</var> to all currently connected WebSocket clients.
   * 
   * @param text
   *            The String to send across the network.
   * @throws InterruptedException
   *             When socket related I/O errors occur.
   */
  public void sendToAll( String text ) {
    Collection<WebSocket> con = connections();
    synchronized ( con ) {
      for ( WebSocket c : con ) {
        c.send( text );
      }
    }
  }
}

//create a separate thread for the server not to freeze/interfere with Processing's default animation thread
public class ServerThread extends Thread {
  @Override
    public void run() {
    try {
      WebSocketImpl.DEBUG = false;
      
      try {
        port = Integer.parseInt( args[ 0 ] );
      } 
      catch ( Exception ex ) {
      }
      server = new PlantServer( port );
      server.start();
      System.out.println( "PlantServer started on port: " + server.getPort() );

      BufferedReader sysin = new BufferedReader( new InputStreamReader( System.in ) );
      while ( true ) {
        String in = sysin.readLine();
        //s.sendToAll( in );
      }
    }
    catch(IOException e) {
      e.printStackTrace();
    }
  }
}

class ClientLoc {

  int type;
  PVector loc;

  public ClientLoc() {
    type = 0;
    loc = new PVector(-4000, -4000);
  }

  public ClientLoc(String message) {
    try {
      int xindex = message.indexOf("X");
      int yindex = message.indexOf("Y");
      type = parseInt(message.substring(1, xindex));
      int x = parseInt(message.substring(xindex+1, yindex));
      int y = parseInt(message.substring(yindex+1));
      loc = getSpawnedXY(x, y);
    }
    catch (Exception e) {
      println("message exception");
      type = 0;
      loc = new PVector(-4000, -4000);
    }
  }

  public void update(String message) {
    try {
      int xindex = message.indexOf("X");
      int yindex = message.indexOf("Y");
      type = parseInt(message.substring(1, xindex));
      int x = parseInt(message.substring(xindex+1, yindex));
      int y = parseInt(message.substring(yindex+1));
      loc = getSpawnedXY(x, y);
    }
    catch(Exception e) {
      println("got an update-related issue");
      //type = "";
      loc = new PVector(-4000, -4000);
    }
  }

  void display(PGraphics s) {
    
    s.pushMatrix();
    displayShovel(s);
    s.popMatrix();
  }

  void displayShovel(PGraphics s) {
    //color[] colors = {color(255, 0, 0), color(255, 255, 0), color(0, 0, 255), color(0, 255, 255), color(255, 0, 255)};
    colorMode(HSB, 100);
    color c = color(type, 100, 100);
    colorMode(RGB, 255);
    
    float shovelH = 300;
    float factor = 1.0* shovelH/shovel.height;
    float shovelW = shovel.width*factor;
    s.translate(loc.x-shovelW/2, loc.y - shovelH, loc.z);
    //s.rotateX(25);
    s.fill(c);
    s.noStroke();
    s.beginShape();
    s.vertex(shovelW*.40, shovelH*.2);
    s.vertex(shovelW*.58, shovelH*.2);
    s.vertex(shovelW*.58, shovelH*.6);
    s.vertex(shovelW*.40, shovelH*.6);
    s.endShape();
    s.translate(0, 0, .5);
    s.shape(shovel, 0, 0, shovelW, shovelH);
  }
}
