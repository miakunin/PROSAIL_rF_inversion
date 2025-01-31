#!/usr/bin/env Rscript

source("functions.R")

Cab <- c(10, 14, 18, 22, 26, 30, 35, 40, 45, 50, 60, 70)
Car <- c(3, 5, 6, 7, 9, 11, 12)
Cbrown <- c(0, 1.0)
Cw <- c(0.002, 0.006, 0.01, 0.014, 0.018)
Cm <- c(0.0005, 0.001, 0.003, 0.005, 0.007, 0.009, 0.011, 0.015)
lai <- c(0.2, 0.6, 1.0, 1.5, 2, 2.5, 3, 3.5, 4, 5, 8)

#lidfa <- c(35,55,75)
lidfa <- c(45,65)
N <- c(1)
hspot <- c(0.01)
psi <- c(0)
tto <- c(0.0)
tts <- c(25, 30, 35, 40, 45, 55, 60)
tts <- c(25, 43, 60)
psoil <- c(0)

parameter_list <- expand.grid(Cab=Cab, Car=Car, Cbrown=Cbrown, Cw=Cw, Cm=Cm, N=N, LAI=lai, TypeLidf=2, lidfa=lidfa, hspot=hspot, tts=tts, tto=tto, psi=psi)
parameter_list <- subset(parameter_list, Cab/Car >= 3 & Cab/Car <= 12) # reducing the size of the parameter list eliminating chloro/caro combinations that were not observed in the lab measurements

var_info(parameter_list)
