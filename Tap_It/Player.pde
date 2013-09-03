public class Player {

  /*********************************
   The Player is reponsible for displaying everything in the game, while the main class
   is responsible for flow control. Player's Deck is simply a pointer to the deck
   instantiated in the main routine, and player and deck position and dimensions are specified
   in the main class
   *********************************/

  private Deck deck; // simply a pointer to the deck instantiated in the main class
  private Card card;
  private float x; // position of player's card
  private float y;

  private int score;
  private boolean locked; // for rotating player's card
  private Timer timer;
  private int timeLimit;
  private int fixedTime;
  private boolean displayFixed; // for fixing display and ensuring committed score is identical to displayed score

  private ArrayList<FadingText> ft; // fading text when player either wins or loses a point

    private float r; // radius of circular card
  private float textSize = .038; // * width
  private final float rotationSpeed = .00001;
  private final color textColor = color(255);
  private final color correctTextColor = color(0, 255, 0);
  private final color wrongTextColor = color(255, 0, 0);

  private PImage back; // back arrow image
  private float backX = 1.05; // * r + x
  private float backY = .75; // * backDim
  private float backDim = .08; // * width

  private float scoreX = .85; // * r + x 
  private float scoreY = .9; // * r + y

  private final color BG = color(50); // background color for board


  // constructor
  public Player(float x, float y, Card c, Deck d, int timeLimit) {

    /********** Set dimensions of back arrow and score, relative to player card **********/
    this.x = x;
    this.y = y;
    r = Tap_It.cardRadius;
    r *= width;

    back = loadImage(Tap_It.path + "images/back.png");
    backDim *= width;
    backX = backX * r + x;
    backY *= backDim;
    scoreX = scoreX * r + x;
    scoreY = scoreY * r + y;

    textSize *= width;


    /********** Initialize timer, score, player card and deck **********/
    this.initialize();
    card = c;
    card.changePosition(x, y);
    deck = d;
    ft = new ArrayList<FadingText>();

    score = 0;
    this.timeLimit = timeLimit;
    timer = new Timer(timeLimit);
    timer.start();
    displayFixed = false;
  }


  public void giveCard(Card c) {
    c.changePosition(x, y);
    card = c;
  }

  public void removeCard() {
    card = null;
  }

  public void giveDeck(Deck d) {
    deck = d;
  }

  public Card getCard() {
    return card;
  }

  public void initialize() {
    timer = new Timer(timeLimit);
    timer.start();
    score = 0;
  }

  // has the player's time run out?
  public boolean timeIsUp() {
    return timer.timeIsUp();
  }

  public int getScore() {
    return score;
  }

  public int timeElapsed() {
    return timer.elapsedTime();
  }

  // for time trial mode, to ensure that committed time and final displayed time are the same 
  public void fixAndDisplayTime(int time) {
    fixedTime = time;
    displayFixed = true;
    displayAndUpdate();
  }





  // update card angle and display it, also display score and lives
  public void displayAndUpdate() {
    background(BG);
    deck.displayDeck();
    deck.displayTopFront();

    // display back arrow
    imageMode(CENTER);
    image(back, backX, backY, backDim, backDim);

    // display player card
    card.updateTheta();
    card.displayFront();
    fill(textColor);
    textSize(textSize);
    text(score, scoreX, scoreY);

    if (Tap_It.mode.equals(Tap_It.SURVIVOR))
      text(timer.remainingTimeToStringMinutes(), scoreX, scoreY + textSize);

    if (Tap_It.mode.equals(Tap_It.TIME_TRIAL) && !displayFixed)
      text(timer.elapsedTimeToStringMinutes(), scoreX, scoreY + textSize);
    if (Tap_It.mode.equals(Tap_It.TIME_TRIAL) && displayFixed)
      text(timer.timeToStringMinutes(fixedTime), scoreX, scoreY + textSize);

    // display fading text for incrementing score
    for (int i = ft.size() - 1; i >=0; i--) {
      FadingText f = ft.get(i);
      if (f.isDead()) ft.remove(i);
      f.displayAndUpdate();
    }
  }



  // if player pushes mouse check to see what symbol in the deck
  // they have clicked on and update their score appropriately
  public void checkClick() {
    if (dist(mouseX, mouseY, x, y) > r) 
      locked = true; // lock out rotation

    // in survivor mode, extraPerCard decreases as player gets more points, slowly approaching zero
    float epcMultiplier = pow( (float) Tap_It.nSyms, Tap_It.extraTimeDecayOrder ) / 
    pow( (float) max(Tap_It.nSyms, score), Tap_It.extraTimeDecayOrder );

    int symbolIndex = deck.indexAtPosition(mouseX, mouseY);
    if (symbolIndex == -1) 
      return; // no symbol was clicked on


    /*********** CORRECT CLICK ************/
    if (card.hasSymbol(symbolIndex)) { 
      score++;

      if (Tap_It.mode.equals(Tap_It.SURVIVOR)) {
        timer.addTime(round(Tap_It.extraPerCard * epcMultiplier));
        ft.add(new FadingText(correctTextColor, "+" + nf(Tap_It.extraPerCard * epcMultiplier / (float) 1000, 1, 1), 
        x + random(-r, r), y + random(-r, r)));
      }
      if (Tap_It.mode.equals(Tap_It.TIME_TRIAL))
        ft.add(new FadingText(correctTextColor, "+1", x + random(-r, r), y + random(-r, r)));

      this.giveCard(deck.removeTop()); // consume a card from the deck

      Tap_It.getPlayer().setMediaFile(Tap_It.CORRECT); // play correct sound whenever player gets one right
      Tap_It.getPlayer().start();
    } 

    /*********** WRONG CLICK ************/
    else {
      if (Tap_It.mode.equals(Tap_It.SURVIVOR))
        timer.subtractTime(Tap_It.PENALTY);
      if (Tap_It.mode.equals(Tap_It.TIME_TRIAL))
        timer.addTimeCountUp(Tap_It.PENALTY);

      ft.add(new FadingText(wrongTextColor, "-" + nf(Tap_It.PENALTY / (float) 1000, 1, 1), 
      x + random(-r, r), y + random(-r, r)));

      Tap_It.getPlayer().setMediaFile(Tap_It.WRONG); // play wrong sound whenever player gets one wrong
      Tap_It.getPlayer().start();
    }
  }



  // player is checking for a click within the back arrow
  public boolean checkBack() {
    // check if player clicked back button to return to splash screen, calls method form main Tap_It program
    return dist(mouseX, mouseY, backX, backY) < backDim / 2.0;
  }

  // this is called in main class whenever mouse is dragged
  public void checkRotate() {
    if (locked) 
      return;
    float alpha = (mouseX - x) * (mouseY - pmouseY) - (mouseY - y) * (mouseX - pmouseX);
    card.incrementOmega(alpha * rotationSpeed);
  }

  public void checkRelease() {
    locked = false;
  }
}

