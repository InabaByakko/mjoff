
  var js,fjs=document.getElementsByTagName('script')[0],p=/^http:/.test(document.location)?'http':'https';
 //if(!document.getElementById('twitter-wjs')){
   
    js=document.createElement('script');
    js.id='twitter-wjs';
    js.src=p+'://platform.twitter.com/widgets.js';
    fjs.parentNode.insertBefore(js,fjs);
  //}
