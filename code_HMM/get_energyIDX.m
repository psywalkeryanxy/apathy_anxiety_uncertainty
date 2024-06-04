function [deltaG,E_b] = get_energyIDX(pi,k_x)
%twoWellPotential illustrate the potential wells of a distcrete 2 state
%system
%   Given a stationary distribution (pi) and the rate of transitions from
%   state 1 to state 2 (k_x), this function will illstrate the potential
%   wells of this system, meaning the depth of each state, as well as the
%   boundary between the states.

% thermodynamics is the relative energy of each state
% kinetics is the rate of transitions between the states

E_x = 1; % where to place our first point, everything else is measured off this
% the choice of E_x is arbitrary

% this is related to the Gibbs free energy of each state via
% pi_x = e^((-E_x/kBT) / Z), where Z is our partition function
%
% if we look at the ratio now, of pi_x / pi_z, the partitions cancel out
%    we are left with pi_x / pi_z = e^((-E_x-E_y)/kBT)
%   so log(pi_x/pi_z) = (-E_x-E_y)/kBT
%
% this is also known as \delta G, or the change in Gibbs free energy
% between the two states
%
% fortunately, we have a 2 state system and we can fix kBT, so:
kBT = 1; % convenience
deltaG = log(pi(1)./pi(2))*kBT;

% ok, now we need to think about the energy barrier between states
%   to do this, we start with the arrhenius rate (k) equations:
%       k_x = A * e ^ (-E_x/kBT)
% but we're going to imagine an new state here, which is our barrier state
%   this has its own energy E_b, and the rate is actually related to depth
%   of E_x relative to this barrier, not in absolute terms!
%       k_x = A * e ^ (-(E_b - E_x)/kBT)
%
% rearranging to solve for E_b, gives us:
%   -kBT*log(k_x/A) + E_x = E_b
A = 0.18; % setting another constant fixed
E_b = - (kBT*log(k_x(1)/A) - E_x);

% E_b should be exactly the same as if we calculate it the other way around
% based on the inverse rate and the deltaG
E_b2 = - (kBT.*log(1-k_x(1)/3./A) - (E_x+deltaG));


end

