#include "chihuahua.hh"

Chihuahua::Chihuahua (std::string name)
    :
    Dog(name)
{
#ifdef TACO_BELL
    m_sound = "Yo quiero Taco Bell!";
#else
    m_sound = "Yip!";
#endif
}
