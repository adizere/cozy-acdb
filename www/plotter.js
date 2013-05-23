var refreshInterval = 1000;
var colors = new Array(5);
colors[0] = 'rgb(0,0,139)';
colors[1] = 'rgb(255,215,0)';
colors[2] = 'rgb(75,0,130)';
colors[3] = 'rgb(144,238,144)';
colors[4] = 'rgb(65,105,225)';

var startingXCenter = 15;
var startingYCenter = 400;

var plotter = new function() {
  this.targetElementName = 'draw';

  this.plotRange = 40;
  this.stateWidth = 30;
  this.stateHeight = 400;
  this.plotCurrentState = 0;
  this.yPivot = startingYCenter + this.stateHeight/2;

  this.start = function() {
    this.initialize();
    this.refresh();
  }

  this.initialize = function() {
    var targetParams = { width: 1400, height: 700 };
    var targetElement = document.getElementById(this.targetElementName);

    this.context = new Two(targetParams);
    this.context.appendTo(targetElement);

    this.plotStates = new Array(this.plotRange + 1);
    for (var i = this.plotStates.length - 1; i >= 0; i--) {
      this.plotStates[i] = new Array(5);
    };
  }

  this.refresh = function() {
    var data = this.retrieveData();
  }

  this.scheduleRefresh = function(interval) {
    console.log("Scheduled a refresh for: " + interval);
    var _this = this;
    setTimeout(function() {_this.refresh()}, interval);
  }

  this.retrieveData = function() {
    console.log("Retrieving data from the server.");

    var start = this.plotCurrentState;
    var end = start + this.plotRange;

    var _this = this;

    var request = $.ajax({
      url: "perl/data_retrieve.pl",
      type: "GET",
      data: {"start": start, "end": end},
      dataType: "json"
    });

    request.done(function(msg) {
      _this.update(msg);
      _this.plotCurrentState += 1;
      _this.scheduleRefresh(refreshInterval);
    });

    request.fail(function(jqXHR, textStatus) {
      console.log( "Request failed: " + textStatus );
    });
  }

  this.update = function(data) {
    var start = this.plotCurrentState;
    var end = start + this.plotRange;

    var states = ['rtt', 'bps', 'lpc', 'conc', 'itw', ];

    var currentStateXPos = startingXCenter;
    var colorPicker = 0;

    var counterState = 0;
    for (var i = start; i <= end; i++) {
      var counterInstance = 0;
      for (var k = 0; k < states.length; k++) {
        var start_height = data[i][states[k]]['start_height'];
        var end_height = data[i][states[k]]['end_height'];
        var total_height = end_height - start_height;

        var currentStateYPos = this.yPivot - start_height - total_height/2;

        if (this.plotStates[counterState][counterInstance]){
          this.plotStates[counterState][counterInstance].remove();
        }

        this.plotStates[counterState][counterInstance] = this.context.makeRectangle(
          currentStateXPos,
          currentStateYPos,
          this.stateWidth,
          total_height);

        this.plotStates[counterState][counterInstance].fill = colors[colorPicker++%5];
        this.plotStates[counterState][counterInstance].opacity = 0.5;
        this.plotStates[counterState][counterInstance].noStroke();

        counterInstance++;
      };

      // Move to the right a bit, for the next state
      currentStateXPos += this.stateWidth + 4;
      counterState++;
    };

    // Update the context with the Two renderer
    this.context.update();
    this.updateHints();
  }

  this.updateHints = function() {
    var st = "";
    var last = this.plotCurrentState;
    for (var i = 0; i <= this.plotRange; i++) {
      st += "<span>" + last + "</span>";
      last++;
    };
    $('#hints').html(st);
  }
}