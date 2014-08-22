describe(VersalChallengesAPI, function() {
  it('reads the challenges from the attributes', function(done) {
    var challenges = [{prompt: 'Sky?', answers: 'blue', scoring: 'strict'}];

    var iframeApi = new VersalChallengesAPI(function(options) {
      chai.expect(options.challenges).to.deep.equal(challenges);
      done();
    });

    window.postMessage({event: 'attributesChanged', data: {'vs-challenges': challenges}}, '*');
  });

  it('reads the scoring from the learnerState', function(done) {
    var scoring = {responses: ['blue'], scores: [1], totalScore: 1};

    var iframeApi = new VersalChallengesAPI(function(options) {
      chai.expect(options.scoring).to.deep.equal(scoring);
      done();
    });

    window.postMessage({event: 'learnerStateChanged', data: {'vs-scores': scoring}}, '*');
  });

  it('saves challenges in the attributes', function(done) {
    var challenges = [{prompt: 'Sky?', answers: 'blue', scoring: 'strict'}];

    window.parent.addEventListener('message', function(event) {
      if (event.data.event === 'setAttributes') {
        window.parent.removeEventListener('message', arguments.callee);

        chai.expect(event.data.data).to.deep.equal({'vs-challenges': challenges});
        done();
      }
    });

    var iframeApi = new VersalChallengesAPI();
    iframeApi.setChallenges(challenges);
  });

  it('saves scoring in the learnerState', function(done) {
    var challenges = [{prompt: 'Sky?', answers: 'blue', scoring: 'strict'}];
    var responses = ['blue'];
    var scoring = {responses: responses, scores: [1], totalScore: 1};

    window.parent.addEventListener('message', function(event) {
      if (event.data.event === 'setLearnerState') {
        window.parent.removeEventListener('message', arguments.callee);

        chai.expect(event.data.data).to.deep.equal({'vs-scores': scoring});
        done();
      }
    });

    var iframeApi = new VersalChallengesAPI();
    iframeApi.setChallenges(challenges);
    iframeApi.scoreChallenges(responses);
  });
});
