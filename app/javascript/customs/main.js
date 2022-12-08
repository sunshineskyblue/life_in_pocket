document.addEventListener('turbolinks:load', function() { 

//============================== HEADER NAVIGATION TOGGLE =========================
  const nav = $('.global-navigation');

  $(document).on('click', e => {
    if (e.target.closest('.user-icon-field') && nav.hasClass('hide-element')) {
      //アイコンをクリックし、navメニューを表示
      nav.addClass('show-element');
      nav.removeClass('hide-element');
    } else if (!e.target.closest('.global-navigation') && nav.hasClass('show-element')){
      //メニュー以外をクリックし、navメニューを非表示
      nav.addClass('hide-element');
      nav.removeClass('show-element');
    } 
  }); 

//============================== FLASH MESSAGE SLIDE =========================

  if (!$('.message-box').hasClass('flash-animation')) {
    $('.message-box').addClass('flash-animation');
  } 

//============================== ROOM SHOW PAGE TOGGLE  =========================
  let i = 0;

  // 要素の非表示部分を取得。非表示があれば、input要素を挿入する。
  $('.room-intro-container .intro-box').each(function() {
    let scrollH = $('.room-intro-container .intro-box').get(i).scrollHeight;
    let offsetH = $('.room-intro-container .intro-box').get(i).offsetHeight;
    let hiddenH = scrollH - offsetH;
    
    if (hiddenH > 0) {
      $('<input id="cp01" type="checkbox">').insertBefore($(this));
      $('<label for="cp01"></label>').insertBefore($(this));
    }
    i++;
  });

});
