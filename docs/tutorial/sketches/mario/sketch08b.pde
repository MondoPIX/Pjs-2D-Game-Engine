final int screenWidth = 512;
final int screenHeight = 432;

float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;

void initialize() {
  frameRate(30);
  addLevel("level", new MarioLevel(4*width, height));  
}

class MarioLevel extends Level {
  MarioLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    setViewBox(0,0,screenWidth,screenHeight);
    addLevelLayer("background", new BackgroundLayer(this));
    addLevelLayer("layer", new MarioLayer(this));
  }
}

class BackgroundLayer extends LevelLayer {
  BackgroundLayer(Level owner) {
    super(owner, owner.width, owner.height, 0,0, 0.75,0.75);
    setBackgroundColor(color(0, 100, 190));
    addStaticSpriteBG(new TilingSprite(new Sprite("graphics/backgrounds/sky_2.gif"),0,0,width,height));
  }
}

class MarioLayer extends LevelLayer {
  Mario mario;
  MarioLayer(Level owner) {
    super(owner);
    addStaticSpriteBG(new TilingSprite(new Sprite("graphics/backgrounds/sky.gif"),0,0,width,height));
    addBoundary(new Boundary(0,height-48,width,height-48));
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    showBoundaries = true;
    mario = new Mario(width/4, height/2);
    addPlayer(mario);

    addGround("ground", -32,height-48, width+32,height);
  
  }

  /**
   * Add some ground.
   */
  void addGround(String tileset, float x1, float y1, float x2, float y2) {
    TilingSprite groundline = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-top.gif"), x1,y1,x2,y1+16);
    addStaticSpriteBG(groundline);
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x1,y1+16,x2,y2);
    addStaticSpriteBG(groundfiller);
    addBoundary(new Boundary(x1,y1,x2,y1));
  }  
  
  void draw() {
    super.draw();
    viewbox.track(parent, mario);
  }
}

class Mario extends Player {
  float speed = 2;
  Mario(float x, float y) {
    super("Mario");
    setupStates();
    setPosition(x,y);
    handleKey('W');
    handleKey('A');
    handleKey('D');
    setForces(0,DOWN_FORCE);
    setAcceleration(0,ACCELERATION);
    setImpulseCoefficients(DAMPENING,DAMPENING);
  }
  void setupStates() {
    addState(new State("idle", "graphics/mario/small/Standing-mario.gif"));
    addState(new State("running", "graphics/mario/small/Running-mario.gif", 1, 4));

    State dead = new State("dead", "graphics/mario/small/Dead-mario.gif", 1, 2);
    dead.setAnimationSpeed(0.25);
    dead.setDuration(100);
    addState(dead);   
   
    State jumping = new State("jumping", "graphics/mario/small/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);

    setCurrentState("idle");    
  }
  void handleStateFinished(State which) {
    setCurrentState("idle");
  }
  void handleInput() {
    if(isKeyDown('A') || isKeyDown('D')) {
      if (isKeyDown('A')) {
        setHorizontalFlip(true);
        addImpulse(-speed, 0);
      }
      if (isKeyDown('D')) {
        setHorizontalFlip(false);
        addImpulse(speed, 0);
      }
    }

    if(isKeyDown('W') && active.name!="jumping" && boundaries.size()>0) {
      addImpulse(0,-35);
      setCurrentState("jumping");
    }
    
    if (active.mayChange()) {
      if(isKeyDown('A') || isKeyDown('D')) {
        setCurrentState("running");
      }
      else { setCurrentState("idle"); }
    }
  }  
  
}