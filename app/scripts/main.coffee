console.log "a-grid GO"

data=[]
chars="0123456789abcdefghijklomnupqrstuvwxyz".split("")
for row in [0...5]
    data[row]?=[]
    for col in [0...20]
        data[row][col]="val_#{col}_#{row}"+ do->
            str=""
            for k in [0...Math.floor(Math.random()*5)]
                str+= chars[Math.floor(Math.random()*chars.length)]
            return str


console.dir data

dataSource=
    data:data
    getCellValue:(row,col)->
        return data[row][col]
    getRowSize:()->
        return this.data.length
    getColSize:()->
        return this.data[0].length
    getCell:(row,col)->

    renderCell:(row,col,el)->
        val=this.getCellValue(row,col)
        #el.append("<div class=\"cell-format\">#{val}</div>")
        el.text("#{val}")
        return el
    getFreezeRowSize:()->
        return 2
    getFreezeColSize:()->
        return 3
    getColWidth:(col)->
        if col < freezeColSize
            tdTop=$("tr:first td:eq(#{col})",ltGridEl)
            tdBottom=$("tr:first td:eq(#{col})",lbGridEl)
            width=Math.max tdTop.width(),tdBottom.width()
        else
            tdTop=$("tr:first td:eq(#{col-freezeColSize})",rtGridEl)
            tdBottm=$("tr:first td:eq(#{col-freezeColSize})",rbGridEl)
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
do ()->
    #init
    ds=dataSource
    gridEl=$(".a-grid")
    ltGridEl=rtGridEl=lbGridEl=rbGridEl=null

    getScrollBarSize=_.once ()->
        gridEl.append("<div class='p'><div class='s'>initialize</div></div>")
        $(".p",gridEl).css("overflow","scroll")
        w=$(".p",gridEl).width()-$(".s",gridEl).width()
        $(".p",gridEl).remove()
        return w
    render=()->
        console.log "render"
        createGrid()
        freezeGrid()
        layoutGrid()
        bindEventOnGrid()
    createGrid=()->
        console.log "==createGrid=="
        colSize=ds.getColSize()
        rowSize=ds.getRowSize()
        freezeColSize=ds.getFreezeColSize()
        freezeRowSize=ds.getFreezeRowSize()

        gridEl.empty().append """
            <div class="grid-main">
                <div class="grid-lt"></div>
                <div class="grid-rt"></div>
                <div class="grid-lb"></div>
                <div class="grid-rb"></div>
            </div>
        """
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
                ###
                top=rbGridEl.scrollTop()
                if e.originalEvent.deltaY > 0
                    rbGridEl.scrollTop(top+rbGridEl.height()*0.33)
                else if e.originalEvent < 0
                    rbGridEl.scrollTop(top-rbGridEl.height()*0.33)
                ###
    #===test======


    _.defer ()->
        render()

