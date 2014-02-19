console.log "a-grid GO"

data=[]
for row in [0...100]
    data[row]?=[]
    for col in [0...5]
        data[row][col]="val_#{row}_#{col}"
console.dir data

dataSource=
    data:data
    getCellValue:(row,col)->
        return data[row][col]
    getRowSize:()->
        return this.data.length
    getColSize:()->
        return this.data[0].length
    renderCell:(row,col,el)->
        val=this.getCellValue(row,col)
        el.append("<div class=\"cell-format\">#{val}</div>")
        return el
    getFreezeRowSize:()->
        return 0
    getFreezeColSize:()->
        return 0
    renderCol:(col,els)->
    renderRow:(row,els)->
    onRenderGrid:()->
    onAfterRender:()->

do ()->
    ds=dataSource
    gridEl=$(".a-grid")
    console.dir gridEl
    render=()->
        gridEl.empty().append """
            <div class="grid-lt"></div>
            <div class="grid-rt"></div>
            <div class="grid-lb"></div>
            <div class="grid-rb"></div>
        """
        ltGridEl=$(".grid-lt",gridEl)
        rtGridEl=$(".grid-rt",gridEl)
        lbGridEl=$(".grid-lb",gridEl)
        rbGridEl=$(".grid-rb",gridEl)
        _.each [ltGridEl,rtGridEl,lbGridEl,rbGridEl],(el)->
            el.append """
                <table>
                    <thead></thead>
                    <tbody></tbody>
                </table>
            """
        colSize=ds.getColSize()
        freezeColSize=ds.getFreezeColSize()
        rowSize=ds.getRowSize()
        freezeRowSize=ds.getFreezeRowSize()
        #LEFT-TOP
        do ()->
            trEls=[]
            for row in [0...freezeRowSize]
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
        do ()->
            trEls=[]
            for row in [0...freezeRowSize]
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
        do ()->
            trEls=[]
            for row in [freezeRowSize...rowSize]
                tdEls=[]
                for col in [0...freezeColSize]
                    tdEl=$("<td class=\"grid-cell grid-col-#{col} grid-row-#{row} grid-cell-#{col}-#{row}\"></td>")
                    tdEl=ds.renderCell(row,col,tdEl)
                    tdEls.push(tdEl)
                trEl=$("<tr class=\"grid-row-#{row}\"></tr>")
                trEl.append tdEls
                trEls.push(trEl)
            $("tbody",lbGridEl).empty().append(trEls)

        #LEFT-BOTTOM
        do ()->
            trEls=[]
            for row in [freezeColSize...rowSize]
                tdEls=[]
                for col in [freezeRowSize...colSize]
                    tdEl=$("<td class=\"grid-cell grid-col-#{col} grid-row-#{row} grid-cell-#{col}-#{row}\"></td>")
                    tdEl=ds.renderCell(row,col,tdEl)
                    tdEls.push(tdEl)
                trEl=$("<tr class=\"grid-row-#{row}\"></tr>")
                trEl.append tdEls
                trEls.push(trEl)
            $("tbody",rbGridEl).empty().append(trEls)

        #LAYOUT
        do ()->
            console.log "LAYOUT"
            paddingTop=ltGridEl.height() or 0
            paddingLeft=ltGridEl.width() or 0
            ltGridEl.css 
                position:'absolute'
                left: 0
                top: 0
            rtGridEl.css 
                position:'absolute'
                left: paddingLeft+"px"
                top: 0
            lbGridEl.css 
                position:'absolute'
                left: 0
                top: paddingTop+"px"
            rbGridEl.css 
                position:'absolute'
                top: paddingTop+"px"
                left: paddingLeft+"px"

    #===test======



    render()
                

