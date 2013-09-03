public class Slider<Item> {
  
  /*
  The constructor for this DISCRETE slider accepts integer inputs for its rectangle specifications,
   and then a generic array of objects that are the permitted values for the slider. The slider always 
   returns one of these objects when getValue() is called, and it displays itself by calling
   Object.toString() on whichever object is currently chosen. The initial index and name of the slider
   are also specified in the constructor
   */
   
  int topcornerx, topcornery; // location of slider
  int dimx, dimy, dim; // width and height, slider horizontal if dim bigger
  float xbutton, ybutton; // value returned by slider, button position
  int ticks, tickval;
  Object[] values;

  float tickspacing, tickspacingclick; // computing these variables in setup makes slider run faster
  float minxpos, maxxpos, minypos, maxypos, buttonsize, buttonsizex, buttonsizey;
  color colorbox, coloractive, colorbutton, textcolor;
  boolean toggleMove, over, lockout; // lockout prevents 2 sliders from being activated at once
  String slidername;
  final float roundedFraction = .1; // how rounded are button edges?
  final float buttonSizeFraction = .085; // make active region of button larger or smaller than drawn button
  float TEXTSIZE = .025; // * width
  


  /** Constructor **/
  Slider (int topcornerx, int topcornery, int dimx, int dimy, 
  Item[] values, int initialIndex, String slidername) {
    this.topcornerx = topcornerx; 
    this.topcornery = topcornery;
    this.dimx = dimx; 
    this.dimy = dimy;
    this.slidername = slidername;

    this.values = new Object[values.length];
    for (int i = 0; i < values.length; i++) 
      this.values[i] = values[i];
    ticks = values.length;
    tickval = constrain(initialIndex, 0, values.length - 1);

    dim = max(dimx, dimy);
    buttonsize = dim * buttonSizeFraction;

    if (dimx >= dimy) {
      buttonsizex = buttonsize;
      buttonsizey = dimy;
      minxpos = topcornerx - buttonsizex / 2.0;
      maxxpos = topcornerx + dimx + buttonsizex / 2.0;
      minypos = topcornery; 
      maxypos = topcornery + buttonsizey;
      xbutton = topcornerx + round( dim * tickval / (float) values.length);
      ybutton = topcornery + buttonsizey / 2.0;
    } 
    else {
      buttonsizex = dimx;
      buttonsizey = buttonsize;
      minxpos = topcornerx; 
      maxxpos = topcornerx + buttonsizex;
      minypos = topcornery - buttonsizey / 2.0; 
      maxypos = topcornery + dimy + buttonsizey / 2.0;
      xbutton = topcornerx + buttonsizex / 2.0;
      ybutton = topcornery + round( dim * tickval / (float) values.length);
    }

    colorbox = #0093CB; 
    coloractive = #00FFFD; 
    colorbutton = #FFFFFF;
    textcolor = color(255);
    TEXTSIZE *= width;

    tickspacing = dim / (float) (ticks - 1);
    tickspacingclick = dim / (float) ticks;
    if (dimx >= dimy)
      xbutton = topcornerx + tickval * tickspacing;
    else
      ybutton = topcornery + tickval * tickspacing;
  }

  void update() {
    if (mouseX > minxpos && mouseX < maxxpos && 
      mouseY > minypos && mouseY < maxypos) over=true;
    else over = false;

    if (over && mousePressed && !lockout) toggleMove = true;

    if (mousePressed && !over && toggleMove==false) lockout = true;

    if (mousePressed == false) {
      toggleMove = false;
      lockout = false;
    }

    if (toggleMove) {

      if (dimx >= dimy) {
        tickval = constrain(floor((mouseX - topcornerx) / tickspacingclick), 0, ticks - 1);
        xbutton = topcornerx + tickval * tickspacing;
      }
      else {
        tickval = constrain(floor((mouseY - topcornery) / tickspacingclick), 0, ticks - 1);
        ybutton = topcornery + tickval * tickspacing;
      }
    }
  }



  /** Display and update **/
  void display() {

    stroke(0);
    rectMode(CORNER);

    if ((over || toggleMove) && !lockout) fill(coloractive);
    else fill(colorbox);

    if (dimx >= dimy) rect(topcornerx - 1.5 * buttonsizex, topcornery, dim + 3 * buttonsizex, buttonsizey, dim * roundedFraction);
    else rect(topcornerx, topcornery - 1.5 * buttonsizey, buttonsizex, dim + 3 * buttonsizey, dim * roundedFraction);

    rectMode(CENTER);
    fill(colorbutton, 185);
    rect(xbutton, ybutton, buttonsizex, buttonsizey);

    textAlign(LEFT);
    textSize(TEXTSIZE);
    fill(textcolor);

    String sliderText = new String();
    if (slidername.length() == 0) 
      sliderText = values[tickval].toString();
    else 
      sliderText = slidername + "  :  " + values[tickval].toString();
      
    if (dimx >= dimy)
      text(sliderText, minxpos, minypos - .01 * height);
    else 
      text(sliderText, minxpos, minypos - 1.5 * buttonsizey - .01 * height);
  }



  /***** Return current value of slider *****/
  Item getValue() {
    return (Item) values[tickval];
  }

  void changeTextColor(color c) {
    textcolor = c;
  }

  void changeSliderColor(color cbox, color cactive, color cbutton) {
    colorbox = cbox; 
    coloractive = cactive; 
    colorbutton = cbutton;
  }
}
