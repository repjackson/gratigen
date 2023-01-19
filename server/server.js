Meteor.methods({
  updateFrequency : function(letter,frequency){
    Letters.update({letter:letter},
      {$set:{frequency:frequency}});
  }
});

