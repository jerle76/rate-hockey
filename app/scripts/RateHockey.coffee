define [ 'require'
         'EaselJS'
         'GameBoard'
         'SoundJS' ], (require) ->

  GameBoard = require 'GameBoard'

  class RateHockey

    constructor: ->
      # initialize sound system and load sound assets
      if not createjs.Sound.initializeDefaultPlugins()
        console.error 'createjs.Sound failed to initialize'
        return

      soundFile = document.getElementById('victory').dataset.audio
      createjs.Sound.registerSound soundFile, 'worldklass'

      # initialize graphic system
      stage = new createjs.Stage 'canvas'
      createjs.Touch.enable stage
      createjs.Ticker.setFPS 60
      createjs.Ticker.setPaused true

      @board = new GameBoard stage,
        debug: false
        black: '#223'
        puckRadius: 85
        puckBorder: 5
        currencies: [ {
           text: 'EUR'
           symbol: '€'
           color: '#2b2'
          }, {
            text: 'GBP'
            symbol: '£'
            color: '#b22'
          }, {
            text: 'USD'
            symbol: '$'
            color: '#22b'
          }
        ]
        winningCallback: @showVictoryScreen
        winningScore: 75
        # percentage of velocity loss per second when gliding freely
        friction: 0.15
        # percentage of velocity remaining when colliding
        collisionFriction: 0.80
        # magic velocity multiplier when releasing puck
        releaseBoost: 2
        # delta in ms between move and release event above which the puck lost all its velocity
        stationaryTime: 250
        # max distance from board centre in percentage where puck can be added
        maxDistance: 0.10
        # max number of puck in play at anytime
        maxPucks: 6
        # puck creation probability divider
        probabilityDivider: 20
        # time in ms for a puck to appear once created
        puckFadeIn: 750
        # time in ms for score animation when a goal is scored
        scoreBounce: 250

    showStartScreen: ->
      ga 'send', 'pageview', '/rate-hockey/start'

      document.body.dataset.show = 'start'

    showGameScreen: ->
      ga 'send', 'pageview', '/rate-hockey/game'

      document.body.dataset.show = 'game'

      @board.start()

    showVictoryScreen: (winner) =>
      ga 'send', 'pageview', '/rate-hockey/victory'
      ga 'send', 'event', 'game', "victory:player #{winner.id}", "score:#{winner.score}"

      @board.stop()

      document.getElementById('playerId').textContent = winner.id
      document.getElementById('victory').className = if winner.id is 1 then 'screen flipped' else 'screen'
      document.body.dataset.show = 'victory'

      instance = createjs.Sound.play 'worldklass',
        volume: 1

      if instance.playState is createjs.Sound.PLAY_FAILED
        console.error 'createjs.Sound failed to play mp3'

      setTimeout ( => @showStartScreen() ), 5000

