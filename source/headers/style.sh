#!/usr/bin/env bash

##########################################################################
# Style
# ------
# Used by output methods
##########################################################################

export DC_OUTPUT_H1_START=( bold smul "setaf $DC_COLOR_WHITE" )
export DC_OUTPUT_H1_END=( sgr0 rmul op )

export DC_OUTPUT_H2_START=( bold smul "setaf $DC_COLOR_WHITE" )
export DC_OUTPUT_H2_END=( sgr0 rmul op )

export DC_OUTPUT_EMPHASIS_START=bold
export DC_OUTPUT_EMPHASIS_END=sgr0

export DC_OUTPUT_STRONG_START=( bold "setaf $DC_COLOR_RED" )
export DC_OUTPUT_STRONG_END=( sgr0 op )

export DC_OUTPUT_RULE_START=( bold smul )
export DC_OUTPUT_RULE_END=( sgr0 rmul )

export DC_OUTPUT_QUOTE_START=bold
export DC_OUTPUT_QUOTE_END=sgr0
