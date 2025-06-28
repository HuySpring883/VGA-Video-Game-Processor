<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan3e" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <blockdef name="SynchronizationCalculator">
            <timestamp>2023-11-30T20:22:45</timestamp>
            <rect width="256" x="64" y="-256" height="256" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="384" y1="-224" y2="-224" x1="320" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
            <line x2="384" y1="-96" y2="-96" x1="320" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
        </blockdef>
        <block symbolname="SynchronizationCalculator" name="XLXI_4">
            <blockpin name="Clk" />
            <blockpin name="Cl_Hcount" />
            <blockpin name="CL_Vcount" />
            <blockpin name="H" />
            <blockpin name="V" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="816" y="832" name="XLXI_4" orien="R0">
        </instance>
    </sheet>
</drawing>