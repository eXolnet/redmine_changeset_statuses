window.addEventListener('load', function() {
  var revisionLinks = document.querySelectorAll('#issue-changesets a[href*="/revisions/"]:not([href$="diff"])');

  for (i = 0; i < revisionLinks.length; ++i) {
    (function(revisionLink) {
      fetch(revisionLink.href +'/status.json', {
        headers: {
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        .then(function(response) {
          return response.json();
        })
        .then(function(data) {
          if (! data.state) {
            return;
          }

          var details = document.createElement('details');

          details.className = 'changeset-status__popover';
          details.setAttribute('role', 'menu');

          details.innerHTML = '<summary aria-haspopup="menu" class="changeset-status changeset-status--'+ data.state +'">•</summary>' +
            '<div class="changeset-status__popup"><ul></ul></div>';

          var ul = details.querySelector('ul');

          data.statuses.forEach(function(status) {
            var li = document.createElement('li');
            li.innerHTML = '<span class="changeset-status changeset-status--'+ status.state +'">•</span> <strong></strong>'

            var strong = li.querySelector('strong');

            if (status.target_url) {
              var a = document.createElement('a');

              a.setAttribute('href', status.target_url);
              a.setAttribute('target', '_blank');
              a.setAttribute('rel', 'noopener noreferrer');

              a.innerText = status.context;

              strong.appendChild(a);
            } else {
              strong.innerText = status.context;
            }

            if (status.description) {
              var em = document.createElement('em');

              em.setAttribute('title', status.description);
              em.innerText = status.description;

              li.appendChild(em);
            }

            ul.appendChild(li);
          });

          revisionLink.parentNode.insertBefore(details, revisionLink);
        });
    })(revisionLinks[i]);
  }
});
