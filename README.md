AIRScroll
=========

Touch scroll to be used on Adobe AIR applications for mobile devices


Usage:


//Create a new AIRScroll object:

var s:AIRScroll = new AIRScroll();

//Then call:

s.addAIRScroll(movie_clip,new Rectangle(movie_clip.x, movie_clip.y, 200, movie_clip.width),'VERTICAL',true);

//Before applying the scroll on another movieClip:

s.removeAIRScroll();
