angular.module 'mnoEnterpriseAngular'
  .controller 'IndexController', ($scope, $sce, GOOGLE_TAG_CONTAINER_ID, INTERCOM_ID, AnalyticsSvc) ->
    'ngInject'

    $scope.google_tag_scripts = $sce.trustAsHtml("""
        <noscript>
            <iframe src=\"\/\/www.googletagmanager.com/ns.html?id=#{GOOGLE_TAG_CONTAINER_ID}\" height=\"0\" width=\"0\" style=\"display:none;visibility:hidden\"></iframe>
        <\/noscript>
        <script>
            (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push(
            {'gtm.start': new Date().getTime(),event:'gtm.js'}
            );var f=d.getElementsByTagName(s)[0],
            j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
            '//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
            })(window,document,'script','dataLayer', '#{GOOGLE_TAG_CONTAINER_ID}');
        <\/script>
    """)if GOOGLE_TAG_CONTAINER_ID?
    
    # It will load the library only if INTERCOM_ID is provided
    angular.element(document).ready(-> addIntercom() if INTERCOM_ID)

    # This is the intercom code translated to coffee and slightly modified to
    # load dinamically the library.
    addIntercom = () ->
      w = window
      w.intercomSettings = 'widget': 'activator': '#IntercomDefaultWidget'
      i = ->
        i.c arguments
        return
      i.q = []
      i.c = (args) ->
        i.q.push args
        return
      w.Intercom = i
      d = document
      s = d.createElement('script')
      s.type = 'text/javascript'
      s.async = true
      s.src = 'https://widget.intercom.io/widget/' + INTERCOM_ID
      x = d.getElementsByTagName('script')[0]
      x.parentNode.insertBefore s, x

      s.onload = () ->
        ic = w.Intercom
        ic 'reattach_activator'
        ic 'update', intercomSettings
      # We make sure the intercom boot happens after we have the intercom loaded
      AnalyticsSvc.init()
      return

    return
