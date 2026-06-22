(function(){
  function initNav(){
    var btn=document.getElementById('navToggle');
    var nav=document.getElementById('navMenu');
    if(!btn||!nav)return;
    var backdrop=document.createElement('div');
    backdrop.className='mobile-nav-backdrop';
    document.body.appendChild(backdrop);
    function setOpen(open){
      nav.classList.toggle('open',open);
      btn.classList.toggle('active',open);
      backdrop.classList.toggle('open',open);
      document.body.classList.toggle('nav-open',open);
      btn.setAttribute('aria-expanded',open?'true':'false');
      btn.setAttribute('aria-label',open?'Close navigation':'Open navigation');
    }
    btn.addEventListener('click',function(){setOpen(!nav.classList.contains('open'))});
    backdrop.addEventListener('click',function(){setOpen(false)});
    nav.querySelectorAll('a').forEach(function(a){a.addEventListener('click',function(){setOpen(false)})});
    document.addEventListener('keydown',function(e){if(e.key==='Escape')setOpen(false)});
    window.addEventListener('resize',function(){if(window.innerWidth>980)setOpen(false)});
  }
  function initFAQ(){
    document.querySelectorAll('.faq-item').forEach(function(i){
      var q=i.querySelector('.faq-question');
      if(!q)return;
      q.addEventListener('click',function(){
        var o=i.classList.toggle('open');
        q.setAttribute('aria-expanded',o?'true':'false');
      });
    });
  }
  function initTop(){
    var b=document.getElementById('backToTop');
    if(!b)return;
    window.addEventListener('scroll',function(){b.classList.toggle('visible',window.scrollY>520)});
    b.addEventListener('click',function(){window.scrollTo({top:0,behavior:'smooth'})});
  }
  function initTheme(){
    var b=document.getElementById('themeToggle');
    if(!b)return;
    var k='oopbuy-theme',s=localStorage.getItem(k);
    if(s==='dark')document.body.classList.add('dark');
    b.textContent=document.body.classList.contains('dark')?'☀️':'🌙';
    b.addEventListener('click',function(){
      document.body.classList.toggle('dark');
      var x=document.body.classList.contains('dark');
      localStorage.setItem(k,x?'dark':'light');
      b.textContent=x?'☀️':'🌙';
      b.setAttribute('aria-label',x?'Switch to light mode':'Switch to dark mode');
    });
  }
  initNav();initFAQ();initTop();initTheme();
})();
