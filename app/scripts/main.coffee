console.log "a-grid GO"


$.fn.aGrid=(options)->
    #helper
    _getScrollBarSize=_.once ()->
        p=$("<div class='p' style='visibility:hidden;'><div class='s'>initialize</div></div>")
        $("body").append(p)
        p.css("overflow","scroll")
        w=p.width()-$(".s",p).width()
        p.remove()
        return w

    _defaultOptions= 
        #implement
        data:do()->
            _data=[]
            chars="0123456789abcdefghijklomnupqrstuvwxyz".split("")
            for row in [0...5]
                _data[row]?=[]
                for col in [0...20]
                    _data[row][col]="val_#{col}_#{row}"+ do->
                        str=""
                        for k in [0...Math.floor(Math.random()*5)]
                            str+= chars[Math.floor(Math.random()*chars.length)]
                        return str
            console.log "==data=="
            console.dir _data 
            return _data
        getCellValue:(row,col)->
            return this.data[row][col]
        getRowSize:()->
            return this.data.length
        getColSize:()->
            return this.data[0].length
        #overwrite
        renderCell:(row,col,el)->
            val=this.getCellValue(row,col)
            #el.append("<div class=\"cell-format\">#{val}</div>")
            el.text("#{val}")
            return el
        getColWidth:(col)->
            if col < freezeColSize
                tdTop=$("tr:first td:eq(#{col})",ltGridEl)
                tdBottom=$("tr:first td:eq(#{col})",lbGridEl)
                width=Math.max tdTop.width(),tdBottom.width()
            else
                tdTop=$("tr:first td:eq(#{col-freezeColSize})",rtGridEl)
                tdBottom=$("tr:first td:eq(#{col-freezeColSize})",rbGridEl)
                wideh=Math.max tdTop.width(),tdBottom.width()
            return width 
        getRowHeight:(row)->
            if row < freezeRowSize
                tdLeft=$("tr:eq(#{row}) td:first",ltGridEl)
                tdRight=$("tr:eq(#{row}) td:first",rtGridEl)
                height=Math.max tdLeft.height(),tdRight.height()
            else
                tdLeft=$("tr:eq(#{row-freezeRowSize}) td:first",lbGridEl)
                tdRight=$("tr:eq(#{row-freezeRowSize}) td:first",rbGridEl)
                height=Math.max tdLeft.height(),tdRight.height()
            return height
        getGridWidth:()->
            return 800
        getGridHeight:()->
            return 600

    _arguments=arguments
    $(this).each ()->
        if $(this).size()>1
            $(this).aGrid.apply this,_arguments
        else if $(this).size()==1
            self=$(this).get(0)
            do ()->

                gridEl=null
                gridMainEl=null
                ltGridEl=rtGridEl=lbGridEl=rbGridEl=null
                _initGrid=()->
                    gridEl=$(self)
                    console.log "==_initGrid=="
                    colSize=self.aGridOption.getColSize()
                    rowSize=self.aGridOption.getRowSize()
                    gridEl.empty().append """
                        <div class="grid-main">
                            <div class="grid-lt"></div>
                            <div class="grid-rt"></div>
                            <div class="grid-lb"></div>
                            <div class="grid-rb"></div>
                        </div>
                    """

                    gridMainEl=$(".grid-main",gridEl)
                    ltGridEl=$(".grid-lt",gridEl)
                    rtGridEl=$(".grid-rt",gridEl)
                    lbGridEl=$(".grid-lb",gridEl)
                    rbGridEl=$(".grid-rb",gridEl)

                    _.each [ltGridEl,rtGridEl,lbGridEl,rbGridEl],(el)->
                        el.append """
                            <table class="grid-table">
                                <thead></thead>
                                <tbody></tbody>
                            </table>
                        """
                    #fill cell
                    trEls=[]
                    for row in [0...rowSize]
                        trEl=$("<tr></tr>")
                        tdEls=[]
                        for col in [0...colSize]
                            tdEl=$("""<td class="grid-col-#{col} grid-row-#{row} grid-cell-#{col}-#{row} grid-cell"></td>""")
                            self.aGridOption.renderCell(row,col,tdEl)
                            tdEls.push tdEl
                        trEl.append tdEls 
                        trEls.push trEl
                    console.dir trEls
                    $(".grid-table",rbGridEl).append(trEls)

                    #fit table size
                    if rbGridEl.width() < gridEl.width()
                        #pass
                        $(".grid-table",rbGridEl).css(
                            'table-layout','fixed'
                            'width':'auto'
                        )
                    else 
                        $(".grid-table",rbGridEl).css(
                            'table-layout','fixed'
                            'width':'100%'
                        )
                    $("tr:first td",rbGridEl).each ()->
                        $(this).outerWidth $(this).outerWidth()
                    $("tr",rbGridEl).each ()->
                        $(this).outerHeight $(this).outerHeight()

                    $(".grid-table",rbGridEl).css
                        width:$(".grid-table",rbGridEl).outerWidth() 
                        #height:$(".grid-table",rbGridEl).outerHeight() 
                    #save each row amd height width
                #end of _initGrid
                _resetFreezeGrid=()->

                _freezeGrid=(freezeRowSize,freezeColSize)-> 
                    console.log "==_freezeGrid=="
                    freezeRowSize?=self.aGridOption.getFreezeRowSize()
                    freezeColSize?=self.aGridOption.getFreezeRowSize()
                    rowSize=self.aGridOption.getRowSize()
                    colSize=self.aGridOption.getColSize()

                    if freezeRowSize>0
                        for row in [0...freezeRowSize]
                            $("tr:eq(#{row})",rbGridEl).remove().appendTo($('tbody',rtGridEl))
                    if freezeColSize>0
                        for row in [0...rowSize]
                            if row < freezeRowSize
                                lTr=$("<tr></tr>")
                                rTr=$("tr:eq(#{row})",rtGridEl)
                                attrs = rTr.prop("attributes")
                                _.each attrs,(obj)->
                                    lTr.attr(obj.name,obj.value)
                                rTr.find("td:lt(#{freezeColSize})").appendTo lTr
                                $("tbody",ltGridEl).append(lTr)
                            else 
                                lTr=$("<tr></tr>")
                                rTr=$("tr:eq(#{row-freezeRowSize})",rbGridEl)
                                attrs = rTr.prop("attributes")
                                _.each attrs,(obj)->
                                    lTr.attr(obj.name,obj.value)
                                rTr.find("td:lt(#{freezeColSize})").appendTo lTr
                                $("tbody",lbGridEl).append(lTr)
                    if freezeRowSize>0
                        gridMainEl.addClass("grid-freeze-row")
                    else
                        gridMainEl.removeClass("grid-freeze-row")
                    if freezeColSize>0
                        gridMainEl.addClass("grid-freeze-col")
                    else
                        gridMainEl.removeClass("grid-freeze-col")
                _layoutGrid=()->
                    console.log "==_layoutGrid=="
                    defaultCss=
                        width:rbGridEl.outerWidth()
                        #height:rbGridEl.outerHeight()
                    $(".grid-table",ltGridEl).css defaultCss
                    $(".grid-table",rtGridEl).css defaultCss
                    $(".grid-table",lbGridEl).css defaultCss

                #end of freezeGrid
                _renderGrid=()->
                    gridEl=$(self)
                    gridEl.empty()
                    _initGrid()
                    _freezeGrid(2,3)
                    _layoutGrid()
                _.defer ()->
                    #main code
                    if typeof _arguments[0] is 'string'
                        console.log _arguments[0]
                    else 
                        console.dir self
                        #init elements
                        if !self.aGridOption
                            console.log "init"
                            self.aGridOption=_.defaults _.clone(options or {}),_defaultOptions
                            console.dir self.aGridOption
                            _renderGrid()
                        else 
                            console.error "el has init once"

$(".a-grid:eq(0)").aGrid()

###
    #init
    ds=dataSource
    gridEl=$(".a-grid")
    gridMainEl=null
    ltGridEl=rtGridEl=lbGridEl=rbGridEl=null
    freezeColSize=freezeRowSize=-1

    getScrollBarSize=_.once ()->
        gridEl.append("<div class='p'><div class='s'>initialize</div></div>")
        $(".p",gridEl).css("overflow","scroll")
        w=$(".p",gridEl).width()-$(".s",gridEl).width()
        $(".p",gridEl).remove()
        return w
    render=()->
        console.log "render"
        createGrid()
        freezeGrid(2,3)
        #layoutGrid()
        #bindEventOnGrid()
    createGrid=()->
        console.log "==createGrid=="
        colSize=ds.getColSize()
        rowSize=ds.getRowSize()

        gridEl.empty().append """
            <div class="grid-main">
                <div class="grid-lt"></div>
                <div class="grid-rt"></div>
                <div class="grid-lb"></div>
                <div class="grid-rb"></div>
            </div>
        """
        gridMainEl=$(".grid-main",gridEl)
        ltGridEl=$(".grid-lt",gridEl)
        rtGridEl=$(".grid-rt",gridEl)
        lbGridEl=$(".grid-lb",gridEl)
        rbGridEl=$(".grid-rb",gridEl)

        _.each [ltGridEl,rtGridEl,lbGridEl,rbGridEl],(el)->
            el.append """
                <table class="grid-table">
                    <thead></thead>
                    <tbody></tbody>
                </table>
            """
        #fill cell
        trEls=[]
        for row in [0...rowSize]
            trEl=$("<tr></tr>")
            tdEls=[]
            for col in [0...colSize]
                tdEl=$("""<td class="grid-col-#{col} grid-row-#{row} grid-cell-#{col}-#{row} grid-cell"></td>""")
                ds.renderCell(row,col,tdEl)
                #tdEl.append ds.renderCell(row,col,tdEl)
                tdEls.push tdEl
            trEl.append tdEls 
            trEls.push trEl
        console.dir trEls
        $(".grid-table",rbGridEl).append(trEls)

        #fit table size
        if rbGridEl.width() < gridEl.width()
            #pass
            $(".grid-table",rbGridEl).css(
                'table-layout','fixed'
            )
        else 
            $(".grid-table",rbGridEl).css(
                'table-layout','fixed'
                'width':'100%'
            )
        $("tr:first td",rbGridEl).each ()->
            $(this).outerWidth $(this).outerWidth()
        $("tr",rbGridEl).each ()->
            $(this).outerHeight $(this).outerHeight()
    freezeGrid=(r=-1,c=-1)->
        freezeRowSize=r
        freezeColSize=c
        rowSize=ds.getRowSize()
        colSize=ds.getColSize()

        if freezeRowSize>0
            for row in [0...freezeRowSize]
                $("tr:eq(#{row})",rbGridEl).remove().appendTo($('tbody',rtGridEl))

        if freezeColSize>0
            for row in [0...rowSize]
                if row < freezeRowSize
                    tr=$("<tr></tr>")
                    $("tr td:lt(#{freezeColSize})",rtGridEl).appendTo tr
                    $("tbody",ltGridEl).append(tr)
                else 
                    tr=$("<tr></tr>")
                    $("tr td:lt(#{freezeColSize})",rbGridEl).appendTo tr
                    $("tbody",lbGridEl).append(tr)
        if freezeRowSize>0
            gridMainEl.addClass("grid-freeze-row")
        else
            gridMainEl.removeClass("grid-freeze-row")
        if freezeColSize>0
            gridMainEl.addClass("grid-freeze-col")
        else
            gridMainEl.removeClass("grid-freeze-col")
    layoutGrid=()->
        colSize=ds.getColSize()
        rowSize=ds.getRowSize()

        ltWidth=0
        rtWidth=0
        for col in [0...colSize]
            if col < freezeColSize
                tdTop=$("tr:first td:eq(#{col})",ltGridEl)
                tdBottom=$("tr:first td:eq(#{col})",lbGridEl)
            else
                tdTop=$("tr:first td:eq(#{col-freezeColSize})",rtGridEl)
                tdBottom=$("tr:first td:eq(#{col-freezeColSize})",rbGridEl)
            w=Math.max tdTop.outerWidth(),tdBottom.outerWidth()
            tdTop.outerWidth w
            tdBottom.outerWidth w
            ltWidth+=w if col < freezeColSize
            rtWidth+=w if col >= freezeColSize
        console.log ltWidth,rtWidth
        $(".grid-table",ltGridEl).outerWidth ltWidth
        $(".grid-table",lbGridEl).outerWidth ltWidth

        rtGridEl.outerWidth rtWidth
        rbGridEl.outerWidth rtWidth
        $(".grid-table",rtGridEl).outerWidth rtWidth
        $(".grid-table",rbGridEl).outerWidth rtWidth

        #rtGridEl.outerWidth rtWidth
        #rbGridEl.outerWidth rtWidth
       
    freezeGrid=()->
        console.log "==freeze grid=="
        freezeColSize=ds.getFreezeColSize()
        freezeRowSize=ds.getFreezeRowSize()
        colSize=ds.getColSize()
        rowSize=ds.getRowSize()

        #LEFT-TOP
        trEls=[]
        for row in [0...freezeRowSize]
            if row==0
                colGroupEl="<colgroup>"
                for col in [0...freezeColSize]
                    colGroupEl+="<col class=\"grid-col-#{col}\"></col>"
                colGroupEl+="</colgroup>"
                $(".grid-table",ltGridEl).prepend(colGroupEl)
            tdEls=[]
            for col in [0...freezeColSize]
                tdEl=$("<td class=\"grid-cell grid-col-#{col} grid-row-#{row} grid-cell-#{col}-#{row}\"></td>")
                tdEl=ds.renderCell(row,col,tdEl)
                tdEls.push(tdEl)
            trEl=$("<tr class=\"grid-row-#{row}\"></tr>")
            trEl.append tdEls
            trEls.push(trEl)
        $("tbody",ltGridEl).empty().append(trEls)
        #RIGHT-TOP
        trEls=[]
        for row in [0...freezeRowSize]
            if row==0
                colGroupEl="<colgroup>"
                for col in [freezeColSize...colSize]
                    colGroupEl+="<col class=\"grid-col-#{col}\"></col>"
                colGroupEl+="</colgroup>"
                $(".grid-table",rtGridEl).prepend(colGroupEl)
            tdEls=[]
            for col in [freezeColSize...colSize]
                tdEl=$("<td class=\"grid-cell grid-col-#{col} grid-row-#{row} grid-cell-#{col}-#{row}\"></td>")
                tdEl=ds.renderCell(row,col,tdEl)
                tdEls.push(tdEl)
            trEl=$("<tr class=\"grid-row-#{row}\"></tr>")
            trEl.append tdEls
            trEls.push(trEl)
        $("tbody",rtGridEl).empty().append(trEls)
        #LEFT-BOTTOM
        trEls=[]
        for row in [freezeRowSize...rowSize]
            if row==freezeRowSize
                colGroupEl="<colgroup>"
                for col in [0...freezeColSize]
                    colGroupEl+="<col class=\"grid-col-#{col}\"></col>"
                colGroupEl+="</colgroup>"
                $(".grid-table",lbGridEl).prepend(colGroupEl)
            tdEls=[]
            for col in [0...freezeColSize]
                tdEl=$("<td class=\"grid-cell grid-col-#{col} grid-row-#{row} grid-cell-#{col}-#{row}\"></td>")
                tdEl=ds.renderCell(row,col,tdEl)
                tdEls.push(tdEl)
            trEl=$("<tr class=\"grid-row-#{row}\"></tr>")
            trEl.append tdEls
            trEls.push(trEl)
        $("tbody",lbGridEl).empty().append(trEls)
        #right-BOTTOM
        trEls=[]
        for row in [freezeRowSize...rowSize]
            if row==freezeRowSize
                colGroupEl="<colgroup>"
                for col in [freezeColSize...colSize]
                    colGroupEl+="<col class=\"grid-col-#{col}\"></col>"
                colGroupEl+="</colgroup>"
                $(".grid-table",rbGridEl).prepend(colGroupEl)

            tdEls=[]
            for col in [freezeColSize...colSize]
                tdEl=$("<td class=\"grid-cell grid-col-#{col} grid-row-#{row} grid-cell-#{col}-#{row}\"></td>")
                tdEl=ds.renderCell(row,col,tdEl)
                tdEls.push(tdEl)
            trEl=$("<tr class=\"grid-row-#{row}\"></tr>")
            trEl.append tdEls
            trEls.push(trEl)
        $("tbody",rbGridEl).empty().append(trEls)

    window.layoutGrid=()->
        console.log "==layoutGrid=="
        colSize=ds.getColSize()
        rowSize=ds.getRowSize()
        freezeColSize=ds.getFreezeColSize()
        freezeRowSize=ds.getFreezeRowSize()

        #each col
        totalWidth=0
        ltWidth=0
        for col in [0...colSize]
            if col < freezeColSize
                tdTop=$("tr:first td:eq(#{col})",ltGridEl)
                tdBottom=$("tr:first td:eq(#{col})",lbGridEl)
                width=Math.max(tdTop.width(),tdBottom.outerWidth())
                width=width+width%10
                totalWidth+=width
                ltWidth+=width
                $("colgroup col:eq(#{col})",ltGridEl).width(width)
                $("colgroup col:eq(#{col})",lbGridEl).width(width)
            else
                tdTop=$("tr:first td:eq(#{col-freezeColSize})",rtGridEl)
                tdBottom=$("tr:first td:eq(#{col-freezeColSize})",rbGridEl)
                width=Math.max(tdTop.width(),tdBottom.outerWidth())+10
                width=width+width%10
                totalWidth+=width
                $("colgroup col:eq(#{col-freezeColSize})",rtGridEl).width(width)
                $("colgroup col:eq(#{col-freezeColSize})",rbGridEl).width(width)
        #each row
        totalHeight=0
        ltHeight=0
        for row in [0...rowSize]
            if row < freezeRowSize
                tdLeft=$("tr:eq(#{row}) td:first",ltGridEl)
                tdRight=$("tr:eq(#{row}) td:first",rtGridEl)
                height=Math.max tdLeft.outerHeight(),tdRight.outerHeight()
                height=height+height%10
                console.log height
                totalHeight+=height
                ltHeight+=height
                $("tr:eq(#{row})",ltGridEl).outerHeight(height)
                $("tr:eq(#{row})",lbGridEl).outerHeight(height)
            else
                tdLeft=$("tr:eq(#{row-freezeRowSize}) td:first",lbGridEl)
                tdRight=$("tr:eq(#{row-freezeRowSize}) td:first",rbGridEl)
                height=Math.max tdLeft.outerHeight(),tdRight.outerHeight()
                height=height+height%10
                console.log height
                totalHeight+=height
                $("tr:eq(#{row-freezeRowSize})",rtGridEl).outerHeight(height)
                $("tr:eq(#{row-freezeRowSize})",rbGridEl).outerHeight(height)
        #layouy css
        gridWidth=gridEl.innerWidth()
        gridHeight=gridEl.innerHeight()
        scrollSize=getScrollBarSize()
        console.log ltWidth,ltHeight
        console.log gridWidth,gridHeight
        ltGridEl.css 
            position:'absolute'
            'padding-top': 0
            'padding-left': 0
            'width': "#{ltWidth}px"
            'height':"#{ltHeight}px"
        $(".grid-table",ltGridEl).css
            width:"#{ltWidth}px"
            height:"#{ltHeight}px"
        rtGridEl.css 
            position:'absolute'
            'padding-top': 0
            'padding-left': "#{ltWidth}px"
            'width':"#{gridWidth-ltWidth-scrollSize}"
            'height':"#{ltHeight}px"
        $(".grid-table",rtGridEl).css
            width:"#{totalWidth-ltWidth}px"
            height:"#{ltHeight}px"
        lbGridEl.css 
            position:'absolute'
            'padding-top': ltHeight+"px"
            'padding-left': 0
            'width': "#{ltWidth}px"
            'height': "#{gridHeight-ltHeight-scrollSize}px"
        $(".grid-table",lbGridEl).css
            width:"#{ltWidth}px"
            height:"#{totalHeight-ltHeight}px"
        rbGridEl.css 
            position:'absolute'
            'padding-left': "#{ltWidth}px"
            'padding-top': "#{ltHeight}px"
            'width': "#{gridWidth-ltWidth}px"
            'height': "#{gridHeight-ltHeight}px"
         $(".grid-table",rbGridEl).css
            width:"#{totalWidth-ltWidth}px"
            height:"#{totalHeight-ltHeight}px"
  
    bindEventOnGrid=()->
        console.log "==bindEventOnGrid=="

        rbGridEl.scroll (e)->
            leftVal=$(this).scrollLeft()
            topVal=$(this).scrollTop()
            rtGridEl.scrollLeft(leftVal)
            lbGridEl.scrollTop(topVal)
        _.each [ltGridEl,rtGridEl,lbGridEl],(el)->
            $(el).bind "mousewheel",(e)->
                #pass
                top=rbGridEl.scrollTop()
                if e.originalEvent.deltaY > 0
                    rbGridEl.scrollTop(top+rbGridEl.height()*0.33)
                else if e.originalEvent < 0
                    rbGridEl.scrollTop(top-rbGridEl.height()*0.33)
    #===test======
    ###


