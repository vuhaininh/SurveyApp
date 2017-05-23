$(function(){



  $(document).on('click', '[js-dialog]', function(e) {
    e.preventDefault();
    $this = $(this);
    $.get($this.attr('href'), function(data) {

      $('#dialog-container').html(data);

      if ($('#question_type').val() == 'choose_one') {
        $('#question_options').show();
      } else {
        $('#question_options').hide();
      }

      $('#question_type').on('change', function(){
        console.log(this);
        if ($('#question_type').val() == 'choose_one') {
          $('#question_options').show();
        } else {
          $('#question_options').hide();
        }
      });

      $(".dialog").click(function(e){
        e.stopPropagation();
      });

    }).fail(function (xhr, ajaxOptions, thrownError) {
        alert(xhr.status);
        alert(thrownError);
    });


  });

  $('body').keydown(function(e) {
    if(e.keyCode === 27){
      $('#dialog-container').empty();
    }
  }).click(function(e){
    $('#dialog-container').empty();
  });

  Chart.defaults.global.animationSteps = 20;
  // Chart.defaults.global.animationEasing = "easeInOut";
  // Chart.defaults.global.animation = false;
  Chart.defaults.global.responsive = true;
  Chart.defaults.global.scaleFontColor = "#999";
  Chart.defaults.global.scaleFontFamily = "'Exo 2', 'Ubuntu', 'Segoe UI', 'Droid Sans', Tahoma, san-serif";

  $('.pie-canvas').each(function(index){
    $this = $(this);

    var ctx = this.getContext("2d");

    var data = $this.data('chart');

    var chart = new Chart(ctx).Pie(data);

    var desc = $('.pie-description[data-question="'+ $this.data('question') +'"]');

  });

  $('.bar-canvas').each(function(index){
    $this = $(this);

    var ctx = this.getContext("2d");

    var chart = new Chart(ctx).Bar($this.data('chart'));
  });


  function scrollFeedback(target) {
    $('.feedback-list').scrollTo('.feedback-grid[data-feedback="' + target + '"]', 300).attr('data-feedback', target);
    $('.feedback-card').removeClass('focus');
    $('.feedback-card[data-feedback="' + target + '"]').addClass('focus');
  }

  function scrollFeedbackPrevious() {
    var current = parseInt($('.feedback-list').attr('data-feedback'));
    var total = parseInt($('.feedback-list').attr('data-total'));

    var next = current - 1;
      if (next < 1) { next = total }
      scrollFeedback( next );
  }

  function scrollFeedbackNext() {
    var current = parseInt($('.feedback-list').attr('data-feedback'));
    var total = parseInt($('.feedback-list').attr('data-total'));

    var next = current + 1;
    if (next > total ) { next = 1 }
    scrollFeedback( next );
  }

  scrollFeedback(1);

  $('.feedback-list').on('click', '.feedback-card', function(){
    scrollFeedback($(this).data('feedback'));
  });

  $('[js-feedback="previous"]').click(function (e) {
    scrollFeedbackPrevious();
  });

  $('[js-feedback="next"]').click(function (e) {
    scrollFeedbackNext();
  });

  $(document).keydown(function(e){

    switch(e.which) {
    case 37: // left
      scrollFeedbackPrevious();
    break;

    case 38: // up
    break;

    case 39: // right
      scrollFeedbackNext();
    break;

    case 40: // down
    break;

    default: return; // exit this handler for other keys
    }
  });
});
