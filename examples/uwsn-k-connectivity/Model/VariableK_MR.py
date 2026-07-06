#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jan  8 16:04:13 2023

@author: cagla
"""

import numpy as np
import math as m
import random
# import array as arr
import gurobipy as gp
from gurobipy import GRB
from gurobipy import *
import datetime
import math
import numpy as np

# Runtime Paramaters
node = 30     # total number of nodes
Rate = 0.5    # rate for set of sensor nodes
maxIter = 3

# Parameters
# Dimensions of rectangular prism (km)
dx = 1  # sabit
dy = 3
dz = 0.3  # sabit

t_round = 300             # Round duration (s)
s_k = 1                   # Number of data packets genesated by each sensor node
L_data = 1024             # Data packet size (bits)
L_control = 256           # Control packet size (bits)
largeM = 5000             # LargeM
N_l = 3                   # Total number of paths
xi = 0.25                 # Frequency of control packets
N_R = 1440                # Total number of rounds for network operation
Er_bit = (2 * (10 ** -8))  # Reception energy cost of a single bit (J)
R_b = 2500                # Data rate (bps)
gamma = 1.7               # Interference range multiplier
NodeRate = node*Rate

ks = 1.5                      # Spreading factor
operationFreq = 25            # Operating freq. (kHz)
absorbCoeff = ((0.11 * (operationFreq ** 2)) / (1 + (operationFreq ** 2))) + ((44 * (operationFreq ** 2)
                                                                               )/(4100 + (operationFreq ** 2))) + ((2.75 * (10 ** -4)) * (operationFreq ** 2)) + 0.003
v = (10 ** (absorbCoeff / 10))  # Frequency-dependent component
P0 = (1 * (10 ** -7))         # Desired power level at the input to the receiver

xcoor = []
ycoor = []
zcoor = []
E_t_link = np.zeros((node, node))
Interference = np.zeros((node, node, node))

V = [i for i in range(0, node)]  # all nodes (including the base station)
W = [j for j in range(1, node)]  # all sensor nodes
NL = [l+1 for l in range(0, N_l)]   # all paths
NL_mod = [l+1 for l in range(0, N_l-1)]   # all paths
TL = [tl+1 for tl in range(0, 10)]  # transmission power levels
TL_mod = [tl+1 for tl in range(0, 9)]  # transmission power levels

base_positions = np.array(
    [[dx/2, dy/2, 0], [dx/2, -dy/2, 0], [-dx/2, dy/2, 0], [-dx/2, -dy/2, 0]])

# Rmax level definition
Rmax = 1*np.array([100, 200, 300, 400, 500, 600, 700, 800, 900, 1000])
# Maximum distance that transmission can occur
max_dist = Rmax[9]
# Path loss over the distance Rmax(l)
pathLoss = {(tl): ((Rmax[tl-1] ** ks) *
                   (v ** (Rmax[tl-1] * (10 ** -3)))) for tl in TL}
# Transmission energy cost of a single bit
Et_bit = {(tl): (pathLoss[tl] * P0) for tl in TL}

# Write Results to a file
now = datetime.datetime.now()
dt_string = now.strftime("%d_%m_%Y_%H_%M_%S")
file = open("Results_%s.txt" % dt_string, "w")
file.truncate(0)

# Lower bound on tau
tau_lb = np.zeros((maxIter, len(NL)))
tau_ub = 1e7*np.ones(maxIter)

iterNo = 1
countNo = 1
while countNo <= maxIter:
    random.seed(iterNo)
    index = random.randint(0, 3)
    base_exact = base_positions[index]

    for i in V:
        if i == 0:
            x = base_exact[0]
            y = base_exact[1]
            z = base_exact[2]
            xcoor.insert(i, x)
            ycoor.insert(i, y)
            zcoor.insert(i, z)
        else:
            x = random.uniform(-dx/2, dx/2)
            y = random.uniform(-dy/2, dy/2)
            z = random.uniform(-dz, 0)
            xcoor.insert(i, x)
            ycoor.insert(i, y)
            zcoor.insert(i, z)

    # xcoor= [0, 0.5, 1.0, 1.5]
    # ycoor= [0, 0, 0, 0]
    # zcoor= [0, 0, 0, 0]

    # Calculate the distance between node-i and node-j
    D = {(i, j): (1000 * m.sqrt((xcoor[i] - xcoor[j]) ** 2 + (
        ycoor[i] - ycoor[j]) ** 2 + (zcoor[i] - zcoor[j]) ** 2)) for i in V for j in V}

    A = [(i, j) for i in V for j in V if i !=
         j and D[i, j] <= Rmax[9]]   # links

    # Energy level assign to links
    for i in V:
        for j in V:
            for tl in TL_mod:
                if i == j:
                    E_t_link[i][j] = 0

                elif D[i, j] <= Rmax[0]:
                    E_t_link[i][j] = Et_bit[1]

                elif (D[i, j] <= Rmax[tl]) and (D[i, j] > Rmax[tl-1]):
                    E_t_link[i][j] = Et_bit[tl+1]

                elif D[i, j] > max_dist:
                    E_t_link[i][j] = 1e10

    # Defining interference binary
    for i in V:
        for j in V:
            for m1 in V:
                if i != j and m1 != j and m1 != i:
                    if (gamma * D[j, m1]) >= D[j, i]:
                        Interference[j][m1][i] = 1
                    else:
                        Interference[j][m1][i] = 0

    ####################################
    # OPTIMIZATION MODEL (GUROBI)
    ####################################

    # Create a Model instance
    mdl = gp.Model("Model")
    #  Suppresses all console output from Gurobi.
    mdl.Params.LogToConsole = 0
    #  Suppresses all console output from Gurobi.
    mdl.setParam('OutputFlag', 0)
    # Time limit for obtaining solution (s)
    mdl.setParam("TimeLimit", 3600)
    # Relative MIP gap (10%)
    mdl.setParam('MIPGap', 0.05)
    # Set mipfocus parameter to control solver focus
    # mipfocus values: 0 (Balanced), 1 (Feasibility), 2 (Optimality), 3 (BestBound), 4 (BestObjBound)
    # For example, setting mipfocus to prioritize finding feasible solutions quickly
    mdl.setParam('MIPFocus', 0)

    # Number of packets generated by node-k flowing over the link(ij) on path-l
    f = {(i, j, k, l): mdl.addVar(vtype=GRB.CONTINUOUS, name="f_{0}_{1}_{2}_{3}".format(
        i, j, k, l), lb=0, ub=N_R) for i in V for j in V for k in W for l in NL}
    # Number of control packets generated by node-k flowing over the link(ij) on path-l
    g = {(i, j, k, l): mdl.addVar(vtype=GRB.CONTINUOUS, name="g_{0}_{1}_{2}_{3}".format(
        i, j, k, l), lb=0, ub=N_R) for i, j in A for k in W for l in NL}
    # Integer variable defined as the total number of packets injected into the network by the source node-k on path-l
    p = {(k, l): mdl.addVar(vtype=GRB.CONTINUOUS, name="p_{0}_{1}".format(
        k, l), lb=0) for k in W for l in NL}
    # Binary variable that shows whether the data generated by node-k on path-l flows over the link(ij) or not
    h = {(i, j, k, l): mdl.addVar(vtype=GRB.BINARY, name="h_{0}_{1}_{2}_{3}".format(
        i, j, k, l)) for i, j in A for k in W for l in NL}
    # Energy dissipation of the maximum energy dissipating node
    tau = mdl.addVar(vtype=GRB.CONTINUOUS, name="tau")

    # Adding Constraints
    mdl.addConstrs((f[i, j, k, l] == 0 for i in V for j in V for k in W for l in NL if i ==
                   j or D[i, j] > Rmax[9]), name="NoFlow")

    for i in V:
        for k in W:
            for l in NL:
                if i == k:
                    mdl.addConstr((gp.quicksum(f[i, j, k, l] for j in V if i != j and D[i, j] <= Rmax[9]))-(gp.quicksum(
                        f[j, i, k, l] for j in V if i != j and D[i, j] <= Rmax[9])) == p[k, l], name="FlowBalanceSource")

                elif i == 0:
                    mdl.addConstr((gp.quicksum(f[i, j, k, l] for j in V if i != j and D[i, j] <= Rmax[9]))-(gp.quicksum(
                        f[j, i, k, l] for j in V if i != j and D[i, j] <= Rmax[9])) == -p[k, l], name="FlowBalanceBS")

                else:
                    mdl.addConstr((gp.quicksum(f[i, j, k, l] for j in V if i != j and D[i, j] <= Rmax[9]))-(gp.quicksum(
                        f[j, i, k, l] for j in V if i != j and D[i, j] <= Rmax[9])) == 0, name="FlowBalanceRelayNode")

    mdl.addConstrs((gp.quicksum(p[k, l] for l in NL) == (
        s_k * N_R) for k in W), name="DataGeneratedSource")
    mdl.addConstrs((gp.quicksum(
        f[j, k, k, l] for j in W for l in NL) == 0 for k in W), name="NoLoopBack")
    mdl.addConstrs((f[i, j, k, l] <= (s_k * N_R * h[i, j, k, l])
                   for (i, j) in A for k in W for l in NL), name="BinaryConstraint1")
    mdl.addConstrs((h[i, j, k, l] <= f[i, j, k, l] for (
        i, j) in A for k in W for l in NL), name="BinaryConstraint2")
    mdl.addConstrs((gp.quicksum(h[i, j, k, l] for j in V if i != j and D[i, j] <= Rmax[9])
                   <= 1 for i in W for k in W for l in NL), name="OnlyOneNextHopConstraint")
    mdl.addConstrs((gp.quicksum(h[i, j, k, l] for l in NL) <= 1 for (
        i, j) in A for k in W), name="OneDataPacketOnePathConstraint")
    mdl.addConstrs(((gp.quicksum(f[j, 0, k, (l + 1)] for j in V if j != 0 and D[j, 0] <= Rmax[9])) <= (gp.quicksum(
        f[j, 0, k, l] for j in V if j != 0 and D[j, 0] <= Rmax[9])) for k in W for l in NL_mod), name="PacketPathConstraint")
    mdl.addConstrs(((f[i, j, k, l] - (largeM * (1 - h[i, j, k, l]))) <= p[k, l]
                   for (i, j) in A for k in W for l in NL), name="EliminationST1")
    mdl.addConstrs(((f[i, j, k, l] + (largeM * (1 - h[i, j, k, l]))) >= p[k, l]
                   for (i, j) in A for k in W for l in NL), name="EliminationST2")
    mdl.addConstrs(((f[i, j, k, l] >= 0)
                   for (i, j) in A for k in W for l in NL), name="LowBoundF")
    mdl.addConstrs(((g[i, j, k, l] >= 0)
                   for (i, j) in A for k in W for l in NL), name="LowBoundG")
    mdl.addConstrs((p[k, l] >= 0 for k in W for l in NL), name="LowBoundP")
    mdl.addConstrs((g[i, j, k, l] == (xi * N_R * (h[i, j, k, l] + h[j, i, k, l]))
                   for (i, j) in A for k in W for l in NL), name="DefineG2")
    mdl.addConstrs((gp.quicksum(h[i, j, k, l] for l in NL for j in V if i != j and D[i, j]
                   <= Rmax[9]) <= 1 for i in W for k in W if i != k), name="NodeDisjointCons1")
    mdl.addConstrs((gp.quicksum(h[j, i, k, l] for l in NL for j in V if i != j and D[i, j]
                   <= Rmax[9]) <= 1 for i in W for k in W if i != k), name="NodeDisjointCons2")
    mdl.addConstrs((gp.quicksum((gp.quicksum((E_t_link[i][j] * ((f[i, j, k, l] * L_data) + (g[i, j, k, l] * L_control))) for j in V if i != j and D[i, j] <= Rmax[9]) + gp.quicksum(
        (Er_bit * ((f[j, i, k, l] * L_data) + (g[j, i, k, l] * L_control))) for j in V if i != j and D[i, j] <= Rmax[9])) for k in W for l in NL) <= tau for i in W), name="THEDN_energy_constraint")
    mdl.addConstrs((gp.quicksum(((gp.quicksum((((f[i, j, k, l] * L_data) / R_b) + ((g[i, j, k, l] * L_control) / R_b)) for j in V if i != j and D[i, j] <= Rmax[9])) + (gp.quicksum((((f[j, i, k, l] * L_data) / R_b) + ((g[j, i, k, l] * L_control) / R_b)) for j in V if i != j and D[i, j] <= Rmax[9])) + (
        gp.quicksum((((f[j, m1, k, l] * L_data * Interference[j][m1][i]) / R_b) + ((g[j, m1, k, l] * L_control * Interference[j][m1][i]) / R_b)) for m1 in V if j != m1 and j != i and m1 != i and D[j, m1] <= Rmax[9]))) for l in NL for k in W) <= (N_R * t_round) for i in V), name="BandwidthConstraint")

    k_conn = 3

    while k_conn >= 1:
        mdl.addConstrs((gp.quicksum(h[k, j, k, l] for l in NL for j in V if k !=
                       j and D[k, j] <= Rmax[9]) >= k_conn for k in W), name="kconnectivity1")
        #   for k in W:
        #       if k < NodeRate:
        #           mdl.addConstr(gp.quicksum(h[k, j, k, l] for l in NL for j in V if k != j and D[k, j] <= Rmax[9]) >= k1, name="kconnectivity1")
        #       else:
        #            mdl.addConstr(gp.quicksum(h[k, j, k, l] for l in NL for j in V if k != j and D[k, j] <= Rmax[9]) >= k2, name="kconnectivity2")

        # Minimization
        mdl.ModelSense = gp.GRB.MINIMIZE

        # Set the Objective Function
        objective = tau
        mdl.setObjective(objective)
        # Use Barrier Method
        mdl.setParam('Method', 2)
        # Set the number of threads to use all available CPU cores
        mdl.setParam("Threads", 0)
        # Set the lower bound of variable tau
        # tau.lb = tau_lb[countNo-1, k_conn-1]

        # if k_conn == N_l:
        # Set the lower bound of variable tau
        # tau.ub = tau_ub[countNo-1]

        # Solve the model
        mdl.optimize()

        # do this if the model is infeasible
        if mdl.Status == GRB.INFEASIBLE:
            mdl.computeIIS()
            mdl.write('iismodel.ilp')
            print(
                "seed={}, countNo={}, k_conn={}, -> INFEASIBLE! \n".format(iterNo, countNo, k_conn))
            iterNo += 1
            break

        if mdl.status == gp.GRB.TIME_LIMIT:
            print("TIME LIMIT REACHED!")
            if mdl.objVal != math.isinf(mdl.objVal) != 1:
                # Write results to a text file
                file.write("{}; {}; {:.2f}; {:.2f}; {:.2f} \n".format(
                    countNo, k_conn, mdl.objVal, 100 * mdl.MIPGap, mdl.Runtime))
                print("seed={}, countNo={}, k_conn={}, -> TL: tau={:.2f}, MIP_Gap={:.2f}%, Sol Time={:.2f} s \n".format(
                    iterNo, countNo, k_conn, mdl.objVal, 100 * mdl.MIPGap, mdl.Runtime))
                # Set the new lower bound
                # tau_lb[countNo-1, k_conn-1] = mdl.objVal
                if k_conn == N_l:
                    countNo += 1
                    iterNo += 1
                    k_conn -= 1
                else:
                    k_conn -= 1

            else:
                print("No solution obtained! Generating a new run!")
                iterNo += 1
                break

        if mdl.status == gp.GRB.OPTIMAL:
            # Get the optimal solution as object
            obj = mdl.getObjective()

            # THEDN Energy Value
            THEDN_Energy = obj.getValue()

            # Retrieve the MIP gap
            mip_gap = mdl.MIPGap

            # Solution Time
            ST = mdl.Runtime

            # This prints the non-zero solutions found
            # mdl.printAttr('X')

            # Write results to a text file
            file.write("{}; {}; {:.2f}; {:.2f}; {:.2f} \n".format(
                countNo, k_conn, THEDN_Energy, 100*mip_gap, ST))
            print("seed={}, countNo={}, k_conn={}, > OPTIMAL: tau={:.2f}, MIP_Gap={:.2f}%, Sol Time={:.2f} s \n".format(
                iterNo, countNo, k_conn, THEDN_Energy, 100*mip_gap, ST))

            # Set the new lower bound
            # tau_lb[countNo-1, k_conn-1] = THEDN_Energy

            if k_conn == N_l:
                tau_ub[countNo-1] = THEDN_Energy

            if k_conn == N_l:
                countNo += 1
                iterNo += 1
                k_conn -= 1
            else:
                k_conn -= 1

    # # Post-Processing
    # E_tx = np.zeros(node)
    # E_rx = np.zeros(node)
    # E_total = np.zeros(node)

    # if mdl.status == GRB.OPTIMAL:
    #     # Get the optimal solution of the variables - f & g
    #     fSol = mdl.getAttr('x', f)
    #     gSol = mdl.getAttr('x', g)
    #     for i in W:

    #         E_tx [i] = (gp.quicksum((gp.quicksum((E_t_link[i][j] * ((fSol[i, j, k, l] * L_data) + (gSol[i, j, k, l] * L_control))) for j in V if i != j and D[i, j] <= Rmax[9])) for k in W for l in NL)).getValue()
    #         E_rx [i] = (gp.quicksum((gp.quicksum((Er_bit * ((fSol[j, i, k, l] * L_data) + (gSol[j, i, k, l] * L_control))) for j in V if i != j and D[i, j] <= Rmax[9])) for k in W for l in NL)).getValue()
    #         E_total [i] = (E_tx [i] + E_rx [i])

file.close()
