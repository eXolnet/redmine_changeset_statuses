window.addEventListener('load', function() {
  var revisionLinks = document.querySelectorAll('#issue-changesets a[href*="/revisions/"]:not([href$="diff"])');

  for (i = 0; i < revisionLinks.length; ++i) {
    var revisionLink = revisionLinks[i];

    fetch(revisionLink.href +'/status.json')
      .then(function(response) {
        return response.json();
      })
      .then(function(data) {
        if (! data.state) {
          return;
        }

        revisionLink.classList.add('changeset-status');
        revisionLink.classList.add('changeset-status--'+ data.state);
      });
  }
});
